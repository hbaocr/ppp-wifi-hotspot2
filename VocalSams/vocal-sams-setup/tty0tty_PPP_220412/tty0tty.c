/* ########################################################################

   tty0tty - linux null modem emulator (module)  for kernel > 3.8

   ########################################################################

   Copyright (c) : 2016  VOCAL Technologies, Ltd.

   Based on tty0tty by - Copyright (c) 2013 Luis Claudio Gambôa Lopes
   Based in Tiny TTY driver -  Copyright (C) 2002-2004 Greg Kroah-Hartman (greg@kroah.com)

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

   ######################################################################## */

#undef PRINT_DEBUG
#undef CREATE_PROC_STAT_FILE

#include <linux/kernel.h>
#include <linux/version.h>
#include <linux/errno.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/wait.h>
#include <linux/tty.h>
#include <linux/tty_driver.h>
#include <linux/tty_flip.h>
#include <linux/serial.h>
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,11,0)
#include <linux/sched/signal.h>
#endif
#include <linux/sched.h>
#include <asm/uaccess.h>
#include <linux/proc_fs.h>

//#define dprintf(A)
#define dprintf(A) printk A

#define DRIVER_VERSION "v1.2"
#define DRIVER_AUTHOR "Luis Claudio Gamboa Lopes <lcgamboa@yahoo.com>"
#define DRIVER_DESC "tty0tty null modem driver"

/* Module information */
MODULE_AUTHOR( DRIVER_AUTHOR );
MODULE_DESCRIPTION( DRIVER_DESC );
MODULE_LICENSE("GPL");


#define TTY0TTY_MAJOR		240	/* experimental range */
//#define TTY0TTY_MINORS		8	/* device number, always even*/

/* fake UART values */
//out
#define MCR_DTR		0x01
#define MCR_RTS		0x02
#define MCR_LOOP	0x04
//in
#define MSR_CTS		0x10
#define MSR_CD		0x20
#define MSR_DSR		0x40
#define MSR_RI		0x80

#define PROCFS_NAME "tty0tty"
#define PROCFS_STATS_NAME "tty0tty_stats"

#define MAX_DRIVER_TTY_COUNT 2048

struct tty0tty_driver;

struct tty0tty_stats {
	int write_count;
	int cts_drop_count;
	int throttle_count;
	int throttle_drop_count;
};

struct tty0tty_serial {
	struct tty_struct	*tty;		/* pointer to the tty for this device */
	int					open_count;	/* number of times this port has been opened */
	struct semaphore	sem;		/* locks this structure */

	/* for tiocmget and tiocmset functions */
	int			msr;		/* MSR shadow */
	int			mcr;		/* MCR shadow */

	int			ctsrts_en;

	/* for ioctl fun */
	struct serial_struct	serial;
	wait_queue_head_t		wait;
	struct async_icount		icount;

	/* Driver for this serial port */
	struct tty0tty_driver* driver;

	int index;
	int count;

	int throttle;

	/* Port statistics */
	struct tty0tty_stats stats;
};

struct tty0tty_driver {
	struct tty_driver* driver;
	struct tty_port port[MAX_DRIVER_TTY_COUNT];
	struct tty0tty_serial* serial[MAX_DRIVER_TTY_COUNT];
	int tty_count;
};

static struct proc_dir_entry* g_proc_entry;
static struct semaphore g_module_config_sem;
static int g_tty_pair_count = 4;
#ifdef CREATE_PROC_STAT_FILE
static int g_tty_stat_port = 0;
#endif /* CREATE_PROC_STAT_FILE */
static struct tty0tty_driver g_tnta_driver;
//static struct tty0tty_driver g_tntb_driver;

struct tty0tty_serial* tty0tty_get_pair(struct tty0tty_serial*);


#ifdef PRINT_DEBUG
int tty0tty_report_flow_control (struct tty0tty_serial* serial, int set)
{
	char type[4];
	struct tty0tty_serial* serial_pair;
	
	if (serial == NULL) {
		return -2;
	}
	if (serial->index >= 2) {
		return 0;
	}
	if (serial->index == 0) {
		if (set == 0) {
			if (serial->count < 50) {
				serial->count++;
				return 1;
			}
			serial->count = 0;
		}
	}

	switch (set) {
	case 0:
		strcpy(type, "GET");
		return 0;
		break;
	case 1:
		strcpy(type, "SET");
		break;
	case 2:
		strcpy(type, "OPN");
		break;
	case 3:
		strcpy(type, "CLS");
		break;
	case 4:
		strcpy(type, "WRT");
		break;
	}

	printk(KERN_INFO "%d:%s - DTR:%s\tRTS:%s\tLOP%s\tCTS:%s\tCD:%s\tDSR:%s\tRI:%s\n",
		serial->index, 	type,
		((serial->mcr & MCR_DTR) ? "1":"0"),
		((serial->mcr & MCR_RTS) ? "1":"0"),
		((serial->mcr & MCR_LOOP) ? "1":"0"),
		((serial->msr & MSR_CTS) ? "1":"0"),
		((serial->msr & MSR_CD) ? "1":"0"),
		((serial->msr & MSR_DSR) ? "1":"0"),
		   ((serial->msr & MSR_RI) ? "1":"0"));


	serial_pair = tty0tty_get_pair(serial);

	if (serial_pair) {

	printk(KERN_INFO "%d:%s - DTR:%s\tRTS:%s\tLOP%s\tCTS:%s\tCD:%s\tDSR:%s\tRI:%s\n",
		   serial_pair->index, 	type,
		   ((serial_pair->mcr & MCR_DTR) ? "1":"0"),
		   ((serial_pair->mcr & MCR_RTS) ? "1":"0"),
		   ((serial_pair->mcr & MCR_LOOP) ? "1":"0"),
		   ((serial_pair->msr & MSR_CTS) ? "1":"0"),
		   ((serial_pair->msr & MSR_CD) ? "1":"0"),
		   ((serial_pair->msr & MSR_DSR) ? "1":"0"),
		   ((serial_pair->msr & MSR_RI) ? "1":"0"));
	}


	/* Print the ioctl info to the log file */
//	printk(KERN_INFO "%d:\t%02x\t%02x\n", serial->index, serial->msr, serial->mcr);
	return 0;
}
#endif /* PRINT_DEBUG */

struct tty0tty_serial* tty0tty_get_pair(struct tty0tty_serial* serial)
{
	int index;
	struct tty0tty_serial* rval = NULL;
#if 0
	// Use this if the two drivers thing ever works
	if (serial) {
		index = serial->tty->index;
		if (serial->driver == &g_tnta_driver) {
			rval = g_tntb_driver.serial[index];
		}
		else if (serial->driver == &g_tntb_driver) {
			rval = g_tnta_driver.serial[index];
		}
	}
#endif
#if 1
	// Use this for a single driver with 2*pair_count ttys
	if (serial) {
		index = serial->tty->index;
		if (index % 2 == 0) {
			rval = g_tnta_driver.serial[index + 1];
		}
		else {
			rval = g_tnta_driver.serial[index - 1];
		}
	}
#endif
	return rval;
}

struct tty0tty_driver* tty0tty_driver_from_struct(struct tty_struct* tty)
{
	struct tty0tty_driver* rval = NULL;
	if (tty->driver == g_tnta_driver.driver) {
		rval = &g_tnta_driver;
	}
	//else if (tty->driver == g_tntb_driver.driver) {
	//	rval = &g_tntb_driver;
	//}
	return rval;
}

static int tty0tty_open(struct tty_struct* tty, struct file* file)
{
	struct tty0tty_driver* driver;
	struct tty0tty_serial* serial;
	struct tty0tty_serial* serial_pair;
	int index;

	/* Upon socket open we will:
	 *	1) Enable RTS in our MCR. This will ensure RTS gets set even if
	 *		the application doesn't do flow control.
	 *	2) Check if the peer TTY is open. If it is we will setup our
	 *		MSR based on the peer settings and we will setup the peer MSR
	 *		based on our settings as follows:
	 *			DSR --> On when peer TTY is open
	 *			DCD --> Follows peer DTR
	 *			CTS --> Follows peer RTS
	 */

	/* initialize the pointer in case something fails */
	tty->driver_data = NULL;

	/* get the serial object associated with this tty pointer */
	driver = tty0tty_driver_from_struct(tty);
	index = tty->index;
	serial = driver->serial[index];

	if (!serial) {

		/* first time accessing this device, let's create it */
		serial = kmalloc(sizeof(*serial), GFP_KERNEL);
		if (!serial) {
			return -ENOMEM;
		}

		sema_init(&serial->sem, 1);
		serial->open_count = 0;

		driver->serial[index] = serial;
		serial->driver = driver;

		serial->stats.write_count = 0;
		serial->stats.cts_drop_count = 0;
		serial->stats.throttle_count = 0;
		serial->stats.throttle_drop_count = 0;
	}

	serial->index = index;
	serial->count = 0;

	serial->throttle = 0;

	driver->port[index].tty = tty;
	tty->port = &(driver->port[index]);

	/* register the tty driver */
	down(&serial->sem);

	/* save our structure within the tty structure */
	tty->driver_data = serial;
	serial->tty = tty;

	serial->open_count++;

	up(&serial->sem);

	/* NULL modem connection */
	serial_pair = tty0tty_get_pair(serial);

#ifdef PRINT_DEBUG
	tty0tty_report_flow_control(serial, 2);
	tty0tty_report_flow_control(serial_pair, 2);
#endif /* PRINT_DEBUG */

	serial->mcr = MCR_RTS; //Forcing RTS
	serial->msr = 0;

	if (serial_pair && (serial_pair->open_count > 0)) {
		/* Consider DSR high if the peer is open */
		serial->msr |= MSR_DSR;
		
		/* MSR Should follow peer MCR */
		if (serial_pair->mcr & MCR_RTS) {
			serial->msr |= MSR_CTS;
		}

		if (serial_pair->mcr & MCR_DTR) {
			serial->msr |= MSR_CD;
		}

		/* Peer was opened before us. They need their MSR setup as well */

		/* Indicate that we are open */
		serial_pair->msr |= MSR_DSR;

		if (serial->mcr & MCR_RTS) {
			serial_pair->msr |= MSR_CTS;
		}

		if (serial->mcr & MCR_DTR) {
			serial_pair->msr |= MSR_CD;
		}

		if (serial_pair->throttle) {
			printk(KERN_WARNING"%d: Peer throttle was set. Clearing\n", serial->index);
			serial_pair->throttle = 0;
		}
	}

	serial->ctsrts_en = 0;

#ifdef PRINT_DEBUG
	tty0tty_report_flow_control(serial, 2);
	tty0tty_report_flow_control(serial_pair, 2);
#endif /* PRINT_DEBUG */

	return 0;
}

static void tty0tty_do_close(struct tty0tty_serial *serial)
{
	struct tty0tty_serial *serial_pair;
	unsigned int msr = 0;

	serial_pair = tty0tty_get_pair(serial);
	if (serial->open_count == 1) {
		if (serial_pair && (serial_pair->open_count > 0)) {
			serial_pair->msr = msr;
		}
	}

#ifdef PRINT_DEBUG
	tty0tty_report_flow_control(serial, 3);
	tty0tty_report_flow_control(serial_pair, 3);
#endif /* PRINT_DEBUG */

	down(&serial->sem);

	if (!serial->open_count) {
		/* port was never opened */
		goto exit;
	}

	serial->open_count--;

exit:
	up(&serial->sem);
	return;
}

static void tty0tty_close(struct tty_struct *tty, struct file *file)
{
	struct tty0tty_serial *serial = tty->driver_data;
	if (serial) {
		tty0tty_do_close(serial);
	}
}

static int tty0tty_write(struct tty_struct *tty, const unsigned char *buffer, int count)
{
	struct tty0tty_serial *serial = tty->driver_data;
	struct tty0tty_serial *serial_pair;
	int retval = -EINVAL;
	struct tty_struct *ttyx = NULL;

	if (!serial) {
		return -ENODEV;
	}

	down(&serial->sem);

	if (!serial->open_count) {
		/* port was not opened */
		goto exit;
	}

	serial_pair = tty0tty_get_pair(serial);
	if (serial_pair && (serial_pair->open_count > 0)) {
		ttyx = serial_pair->tty;
	}

	//tds - check "our view" of CTS
#ifdef PRINT_DEBUG
	printk(KERN_INFO "%d:%d:\n", serial_pair->index, count);
	tty0tty_report_flow_control(serial, 4);
	tty0tty_report_flow_control(serial_pair, 4);
#endif /* PRINT_DEBUG */

	if ((serial->msr & MSR_CTS) != MSR_CTS) {
		if (serial->ctsrts_en == 1) {
			serial->stats.cts_drop_count++;
			retval = 0;
			printk(KERN_INFO "%d:CTS Down\n", serial_pair->index);
			goto exit;
		}
	}

	if (serial->throttle != 0) {
		retval = 0;
		serial->stats.throttle_drop_count++;
//		printk(KERN_INFO "%d:Throttle\n", serial->index);
		goto exit;
	}

	if (ttyx) {
		serial->stats.write_count++;
		tty_insert_flip_string(ttyx->port, buffer, count);
		tty_flip_buffer_push(ttyx->port);
		retval = count;
	}

exit:
	up(&serial->sem);
	return retval;
}

static int tty0tty_write_room(struct tty_struct *tty)
{
	struct tty0tty_serial *serial = tty->driver_data;
	int room = -EINVAL;

	if (!serial) {
		return -ENODEV;
	}
	
	down(&serial->sem);

	if (!serial->open_count) {
		/* port was not opened */
		goto exit;
	}

	/* calculate how much room is left in the device */
	if ((serial->ctsrts_en == 1) && ((serial->msr & MSR_CTS) == ~MSR_CTS)) {
		room = 0;
		printk(KERN_INFO "%d:CTS Down, returning 0 room\n", serial->index);
		goto exit;
	}
	room = 255;

exit:
	up(&serial->sem);
	return room;
}

#define RELEVANT_IFLAG(iflag) ((iflag) & (IGNBRK|BRKINT|IGNPAR|PARMRK|INPCK))

static void tty0tty_set_termios(struct tty_struct *tty, struct ktermios *old_termios)
{
	unsigned int cflag;

        struct tty0tty_serial *serial = tty->driver_data;

	cflag = tty->termios.c_cflag;

	/* check that they really want us to change something */
	if (old_termios) {
		if ((cflag == old_termios->c_cflag) && (RELEVANT_IFLAG(tty->termios.c_iflag) == RELEVANT_IFLAG(old_termios->c_iflag))) {
			return;
		}
	}

#if 0
	/* get the byte size */
	switch (cflag & CSIZE) {
		case CS5:
			printk(KERN_DEBUG " - data bits = 5\n");
			break;
		case CS6:
			printk(KERN_DEBUG " - data bits = 6\n");
			break;
		case CS7:
			printk(KERN_DEBUG " - data bits = 7\n");
			break;
		default:
		case CS8:
			printk(KERN_DEBUG " - data bits = 8\n");
			break;
	}
#endif

#if 0
	/* determine the parity */
	if (cflag & PARENB)
		if (cflag & PARODD)
			printk(KERN_DEBUG " - parity = odd\n");
		else
			printk(KERN_DEBUG " - parity = even\n");
	else
		printk(KERN_DEBUG " - parity = none\n");
#endif

#if 0
	/* figure out the stop bits requested */
	if (cflag & CSTOPB)
		printk(KERN_DEBUG " - stop bits = 2\n");
	else
		printk(KERN_DEBUG " - stop bits = 1\n");
#endif

	/* figure out the hardware flow control settings */
	if (cflag & CRTSCTS) {
		serial->ctsrts_en = 1;
		printk(KERN_DEBUG " - RTS/CTS is enabled\n");
	} else {
		serial->ctsrts_en = 0;
		printk(KERN_DEBUG " - RTS/CTS is disabled\n");
	}

#if 0
	/* determine software flow control */
	/* if we are implementing XON/XOFF, set the start and
	 * stop character in the device */
	if (I_IXOFF(tty) || I_IXON(tty)) {
		unsigned char stop_char  = STOP_CHAR(tty);
		unsigned char start_char = START_CHAR(tty);

		/* if we are implementing INBOUND XON/XOFF */
		if (I_IXOFF(tty))
			printk(KERN_DEBUG " - INBOUND XON/XOFF is enabled, "
				"XON = %2x, XOFF = %2x\n", start_char, stop_char);
		else
			printk(KERN_DEBUG" - INBOUND XON/XOFF is disabled\n");

		/* if we are implementing OUTBOUND XON/XOFF */
		if (I_IXON(tty))
			printk(KERN_DEBUG" - OUTBOUND XON/XOFF is enabled, "
				"XON = %2x, XOFF = %2x\n", start_char, stop_char);
		else
			printk(KERN_DEBUG" - OUTBOUND XON/XOFF is disabled\n");
	}
#endif

#if 0
	/* get the baud rate wanted */
	printk(KERN_DEBUG " - baud rate = %d\n", tty_get_baud_rate(tty));
#endif
}

static int tty0tty_tiocmget(struct tty_struct *tty)
{
	struct tty0tty_serial *serial = tty->driver_data;
	unsigned int result;
	unsigned int msr;
	unsigned int mcr;

	if (!serial) {
		return -ENODEV;
	}
	
	result = 0;
	msr = serial->msr;
	mcr = serial->mcr;

	result = ((mcr & MCR_DTR)  ? TIOCM_DTR  : 0) |	/* DTR is set */
             ((mcr & MCR_RTS)  ? TIOCM_RTS  : 0) |	/* RTS is set */
             ((mcr & MCR_LOOP) ? TIOCM_LOOP : 0) |	/* LOOP is set */
             ((msr & MSR_CTS)  ? TIOCM_CTS  : 0) |	/* CTS is set */
             ((msr & MSR_CD)   ? TIOCM_CAR  : 0) |	/* Carrier detect is set*/
             ((msr & MSR_RI)   ? TIOCM_RI   : 0) |	/* Ring Indicator is set */
             ((msr & MSR_DSR)  ? TIOCM_DSR  : 0);	/* DSR is set */

#ifdef PRINT_DEBUG
	tty0tty_report_flow_control(serial, 0);
#endif /* PRINT_DEBUG */

	return result;
}

static int tty0tty_tiocmset(struct tty_struct *tty, unsigned int set, unsigned int clear)
{
	struct tty0tty_serial *serial = tty->driver_data;
	struct tty0tty_serial *serial_pair;
	unsigned int mcr = 0;
	unsigned int msr = 0;

	if (!serial) {
		return -ENODEV;
	}

	mcr = serial->mcr;

	serial_pair = tty0tty_get_pair(serial);
	if (serial_pair && (serial_pair->open_count > 0)) {
		msr = serial_pair->msr;
	}

	/* NULL modem connection */

	if (set & TIOCM_RTS) {
		mcr |= MCR_RTS;
		msr |= MSR_CTS;
		/*- TDS - We want to let the line discipline know that we are
		 * now ready for more data. This call into the TTY susbsytem
		 * should call the write_wakeup() function on the line
		 * discipline. When PPP is installed, this should eventually
		 * call ppp_output_wakeup.
		 * See: Documentation\networking\ppp_generic.txt -*/

		/* Wakeup on the peer TTY */
		if (serial_pair && (serial_pair->open_count > 0)) {
			/*- TDS - Should we still do this when ctsrts flow control is disabled? -*/
			tty_wakeup(serial_pair->tty);
		}
	}

	if (set & TIOCM_DTR) {
		mcr |= MCR_DTR;
		msr |= MSR_DSR;
		msr |= MSR_CD;
	}

	if (clear & TIOCM_RTS) {
		mcr &= ~MCR_RTS;
		msr &= ~MSR_CTS;
	}

	if (clear & TIOCM_DTR) {
		mcr &= ~MCR_DTR;
		msr &= ~MSR_DSR;
		msr &= ~MSR_CD;
	}

	/* set the new MCR value in the device */
	serial->mcr = mcr;

	if (serial_pair && (serial_pair->open_count > 0)) {
		serial_pair->msr = msr;
	}

#ifdef PRINT_DEBUG
	tty0tty_report_flow_control(serial, 1);
#endif /* PRINT_DEBUG */

	return 0;
}


static int tty0tty_ioctl_tiocgserial(struct tty_struct *tty, unsigned int cmd, unsigned long arg)
{
	struct tty0tty_serial *serial = tty->driver_data;

	if (!serial) {
		return -ENODEV;
	}
	
	if (cmd == TIOCGSERIAL) {
		struct serial_struct tmp;

		if (!arg) {
			return -EFAULT;
		}

		memset(&tmp, 0, sizeof(tmp));

		tmp.type		= serial->serial.type;
		tmp.line		= serial->serial.line;
		tmp.port		= serial->serial.port;
		tmp.irq			= serial->serial.irq;
		tmp.flags		= ASYNC_SKIP_TEST | ASYNC_AUTO_IRQ;
		tmp.xmit_fifo_size	= serial->serial.xmit_fifo_size;
		tmp.baud_base		= serial->serial.baud_base;
		tmp.close_delay		= 5*HZ;
		tmp.closing_wait	= 30*HZ;
		tmp.custom_divisor	= serial->serial.custom_divisor;
		tmp.hub6		= serial->serial.hub6;
		tmp.io_type		= serial->serial.io_type;

		if (copy_to_user((void __user *)arg, &tmp, sizeof(struct serial_struct))) {
			return -EFAULT;
		}
		return 0;
	}
	return -ENOIOCTLCMD;
}

static int tty0tty_ioctl_tiocmiwait(struct tty_struct *tty, unsigned int cmd, unsigned long arg)
{
	struct tty0tty_serial *serial = tty->driver_data;

	if (!serial) {
		return -ENODEV;
	}
	
	if (cmd == TIOCMIWAIT) {
		DECLARE_WAITQUEUE(wait, current);
		struct async_icount cnow;
		struct async_icount cprev;

		cprev = serial->icount;
		while (1) {
			add_wait_queue(&serial->wait, &wait);
			set_current_state(TASK_INTERRUPTIBLE);
			schedule();
			remove_wait_queue(&serial->wait, &wait);

			/* see if a signal woke us up */
			if (signal_pending(current)) {
				return -ERESTARTSYS;
			}

			cnow = serial->icount;
			if (cnow.rng == cprev.rng && cnow.dsr == cprev.dsr &&
			    cnow.dcd == cprev.dcd && cnow.cts == cprev.cts)
				return -EIO; /* no change => error */
			if (((arg & TIOCM_RNG) && (cnow.rng != cprev.rng)) ||
			    ((arg & TIOCM_DSR) && (cnow.dsr != cprev.dsr)) ||
			    ((arg & TIOCM_CD)  && (cnow.dcd != cprev.dcd)) ||
			    ((arg & TIOCM_CTS) && (cnow.cts != cprev.cts)) ) {
				return 0;
			}
			cprev = cnow;
		}
	}
	return -ENOIOCTLCMD;
}

static int tty0tty_ioctl_tiocgicount(struct tty_struct *tty, unsigned int cmd, unsigned long arg)
{
	struct tty0tty_serial *serial = tty->driver_data;

	if (!serial) {
		return -ENODEV;
	}
	
	if (cmd == TIOCGICOUNT) {
		struct async_icount cnow = serial->icount;
		struct serial_icounter_struct icount;

		icount.cts	= cnow.cts;
		icount.dsr	= cnow.dsr;
		icount.rng	= cnow.rng;
		icount.dcd	= cnow.dcd;
		icount.rx	= cnow.rx;
		icount.tx	= cnow.tx;
		icount.frame	= cnow.frame;
		icount.overrun	= cnow.overrun;
		icount.parity	= cnow.parity;
		icount.brk	= cnow.brk;
		icount.buf_overrun = cnow.buf_overrun;

		if (copy_to_user((void __user *)arg, &icount, sizeof(icount))) {
			return -EFAULT;
		}
		return 0;
	}
	return -ENOIOCTLCMD;
}

static int tty0tty_ioctl(struct tty_struct *tty, unsigned int cmd, unsigned long arg)
{
	switch (cmd) {
	case TIOCGSERIAL:
		return tty0tty_ioctl_tiocgserial(tty, cmd, arg);
	case TIOCMIWAIT:
		return tty0tty_ioctl_tiocmiwait(tty, cmd, arg);
	case TIOCGICOUNT:
		return tty0tty_ioctl_tiocgicount(tty, cmd, arg);
	}
	return -ENOIOCTLCMD;
}

static void tty0tty_throttle(struct tty_struct *tty)
{
	struct tty0tty_serial* serial;
	struct tty0tty_serial* serial_pair;

	serial = (struct tty0tty_serial*) tty->driver_data;
	if (serial) {
		serial_pair = tty0tty_get_pair(serial);
		serial_pair->throttle = 1;
		serial_pair->stats.throttle_count++;

//		printk(KERN_WARNING"Throttle %d peer is %d\n", serial->index, serial_pair->index);
	}
}

static void tty0tty_unthrottle(struct tty_struct *tty)
{
	struct tty0tty_serial* serial;
	struct tty0tty_serial* serial_pair;

	serial = (struct tty0tty_serial*) tty->driver_data;
	if (serial) {
		serial_pair = tty0tty_get_pair(serial);
		serial->throttle = 0;

//		printk(KERN_WARNING"Unthrottle %d peer is %d\n", serial->index, serial_pair->index);
	}
}

static struct tty_operations serial_ops = {
	.open = tty0tty_open,
	.close = tty0tty_close,
	.write = tty0tty_write,
	.write_room = tty0tty_write_room,
	.set_termios = tty0tty_set_termios,
	.tiocmget = tty0tty_tiocmget,
	.tiocmset = tty0tty_tiocmset,
	.throttle = tty0tty_throttle,
	.unthrottle = tty0tty_unthrottle,
	.ioctl = tty0tty_ioctl
};

static int tty0tty_create_driver (struct tty0tty_driver* d, const char* tty_name, int tty_count)
{
	int i;
	int rval;
	struct tty_driver* driver;

	dprintf((KERN_DEBUG"tty0tty_open_tty() - tty_name: %s, tty_count: %d\n", tty_name, tty_count));

	/* Clear */
	memset(d, 0, sizeof(*d));

	/* Allocate the tty driver */
	driver = tty_alloc_driver(tty_count, TTY_DRIVER_RESET_TERMIOS | TTY_DRIVER_REAL_RAW);
	if (!driver) {
		dprintf((KERN_ERR"tty0tty_create_driver() - tty_alloc_driver returned NULL\n"));
		return -1;
	}
	d->driver = driver;
	
	/* initialize the tty driver */
	driver->owner = THIS_MODULE;
	driver->driver_name = "tty0tty";
	driver->name = tty_name;
	/* no more devfs subsystem */
	//driver->major = TTY0TTY_MAJOR;
	driver->major = 0;
	driver->type = TTY_DRIVER_TYPE_SERIAL;
	driver->subtype = SERIAL_TYPE_NORMAL;
	driver->flags = TTY_DRIVER_RESET_TERMIOS | TTY_DRIVER_REAL_RAW ;
	/* no more devfs subsystem */
	driver->init_termios = tty_std_termios;
	driver->init_termios.c_iflag = 0;
	driver->init_termios.c_oflag = 0;
	driver->init_termios.c_cflag = B38400 | CS8 | CREAD;
	driver->init_termios.c_lflag = 0;
	driver->init_termios.c_ispeed = 38400;
	driver->init_termios.c_ospeed = 38400;

	tty_set_operations(driver, &serial_ops);

	for (i = 0; i < tty_count; i++) {
		tty_port_init(&(d->port[i]));
		tty_port_link_device(&(d->port[i]), driver, i);
	}

	rval = tty_register_driver(driver);
	if (rval) {
		dprintf((KERN_ERR"tty0tty_create_driver() - tty_register_driver failed with error %d\n", rval));
		put_tty_driver(driver);
		return -1;
	}

	d->tty_count = tty_count;
	
	return 0;
}

int tty0tty_destroy_driver(struct tty0tty_driver* d)
{
	int i;

	for (i = 0; i < d->tty_count; i++) {
		tty_port_destroy(&(d->port[i]));
		tty_unregister_device(d->driver, i);
	}

	tty_unregister_driver(d->driver);

	return 0;
}

int tty0tty_open_ttys (void)
{
	int rval;

	if (g_tty_pair_count < 1) {
		/* Count is zero, don't open anything */
		return 0;
	}
	
	// FIXME - Creating the second driver fails
	// To get around this, I'm only creating one driver and using sym-links for nice numbering

	//rval = tty0tty_create_driver(&g_tnta_driver, "tnta", g_tty_pair_count);
	rval = tty0tty_create_driver(&g_tnta_driver, "tnt", 2*g_tty_pair_count);
	if (rval) {
		return -1;
	}

	//rval = tty0tty_create_driver(&g_tntb_driver, "tntb", g_tty_pair_count);
	//if (rval) {
	//	return -1;
	//}

	printk(KERN_INFO"tty0tty - Open succeeded, created %d virtual serial port pairs\n", g_tty_pair_count);
	
	return 0;
}

int tty0tty_driver_check_ttys_open (struct tty0tty_driver* d, int print_open)
{
	struct tty0tty_serial *serial;
	int i;
	int open_count = 0;
	for (i = 0; i < d->tty_count; i++) {
		serial = d->serial[i];
		if (!serial) {
			continue;
		}
		if (serial->open_count > 0) {
			open_count++;
			if (print_open) {
				printk(KERN_INFO"TTY /dev/%s%d is open\n", d->driver->name, i);
			}
		}
	}
	return open_count;
}

int tty0tty_check_ttys_open (int print_open)
{
	int open_count = 0;
	open_count += tty0tty_driver_check_ttys_open(&g_tnta_driver, print_open);
	//open_count += tty0tty_driver_check_ttys_open(&g_tntb_driver, print_open);
	return open_count;
}

int tty0tty_driver_close_ttys (struct tty0tty_driver* d)
{
	struct tty0tty_serial *serial;
	int i;

	if (!(d->driver)) {
		/* Never opened */
		return 0;
	}
	
	for (i = 0; i < d->tty_count; i++) {
		tty_port_destroy(&d->port[i]);
		tty_unregister_device(d->driver, i);
	}
	tty_unregister_driver(d->driver);
	d->driver = NULL;
	
	/* shut down all of the timers and free the memory */
	for (i = 0; i < d->tty_count; i++) {
		serial = d->serial[i];
		if (serial) {

			/* close the port */
			while (serial->open_count) {
				tty0tty_do_close(serial);
			}

			/* shut down our timer and free the memory */
			kfree(serial);
			d->serial[i] = NULL;
		}
	}

	return 0;
}

int tty0tty_close_ttys (void)
{
	tty0tty_driver_close_ttys(&g_tnta_driver);
	//tty0tty_driver_close_ttys(&g_tntb_driver);

	printk(KERN_INFO"tty0tty - Close succeeded\n");
	
	return 0;
}

int tproc_open (struct inode* inode, struct file* file)
{
	try_module_get(THIS_MODULE);
	return 0;
}

int tproc_release (struct inode* inode, struct file* file)
{
	module_put(THIS_MODULE);
	return 0;
}

ssize_t tproc_read (struct file* file, char __user* buf, size_t count, loff_t* f_pos)
{
	char message[32];
	unsigned long len;
	int pos = *f_pos;

	/* If the read position is non-zero, return EOF */
	if (pos > 0) {
		return 0;
	}

	/* Generate the message */
	sprintf(message, "%d\n", g_tty_pair_count);

	/* Make sure the message will fit in the user's buffer, truncate if it won't */
	len = (unsigned long)strlen(message) + 1;
	if (len > count) {
		len = count - 1;
	}

	/* NULL-terminate */
	message[len] = '\0';

	/* Copy the message out to user space */
	copy_to_user(buf, message, (unsigned int) len);

	/* Update the file position */
	*f_pos += len;

	/* Return characters read */
	return len;
}

ssize_t tproc_write (struct file* file, const char __user* buf, size_t count, loff_t* f_pos)
{
	char message[32];
	int len;
	int new_count;
	int rval = 0;

	/* Check the user's buffer size, truncate if it's too big */
	len = count;
	if (len >= sizeof(message)) {
		len = sizeof(message) - 1;
	}

	/* Copy the user's buffer into kernel space */
	copy_from_user(message, buf, len);

	/* NULL-terminate */
	message[len] = '\0';

	/* Grab the new TTY count */
	if (sscanf(message, "%d", &new_count) != 1) {
		return 0;
	}

	/* Validate */
	if (new_count < 0) {
		new_count = 0;
	}
	//else if (new_count > MAX_DRIVER_TTY_COUNT) {
	//	new_count = MAX_DRIVER_TTY_COUNT;
	//}
	else if (new_count > (MAX_DRIVER_TTY_COUNT/2)) {
		new_count = (MAX_DRIVER_TTY_COUNT/2);
	}
	
	down(&g_module_config_sem);
	
	/* If the tty count changed, close the old ones and open new ones */
	if (new_count != g_tty_pair_count) {
		if (tty0tty_check_ttys_open(1) > 0) {
			printk(KERN_WARNING"Unable to change number of TTYs, at least one is still open\n");
			rval = -EBUSY;
			goto exit;
		}
		else {
			rval = tty0tty_close_ttys();
			if (rval) {
				goto exit;
			}

			g_tty_pair_count = new_count;

			rval = tty0tty_open_ttys();
			if (rval) {
				goto exit;
			}
		}
	}

exit:
	up(&g_module_config_sem);
	return count;
}

#if LINUX_VERSION_CODE >= KERNEL_VERSION(5,6,0)
static const struct proc_ops tty_proc_oops = {
	.proc_open = tproc_open,
	.proc_release = tproc_release,
	.proc_read = tproc_read,
	.proc_write = tproc_write
};
#else /* LINUX_VERSION_CODE >= KERNEL_VERSION(5,6,0) */
/* File operations structure for the /proc file */
static const struct file_operations tty_proc_oops = {
	.owner = THIS_MODULE,
	.open = tproc_open,
	.release = tproc_release,
	.read = tproc_read,
	.write = tproc_write
};
#endif /* LINUX_VERSION_CODE >= KERNEL_VERSION(5,6,0) */

int create_proc_file (void)
{
	/* Create the /proc file entry for this kernel module */
	g_proc_entry = proc_create(PROCFS_NAME, 0666, NULL, &tty_proc_oops);
	return 0;
}

void remove_proc_file (void)
{
	/* Remove the /proc file entry for this kernel module */
	remove_proc_entry(PROCFS_NAME, NULL);
}


#ifdef CREATE_PROC_STAT_FILE
ssize_t stats_read (struct file* file, char __user* buf, size_t count, loff_t* f_pos)
{
	char message[512];
	unsigned long len;
	int pos = *f_pos;
	int i;
	struct tty0tty_serial* serial;
	struct tty0tty_serial* serial_pair;

	/* If the read position is non-zero, return EOF */
	if (pos > 0) {
		return 0;
	}


	serial = g_tnta_driver.serial[g_tty_stat_port];

	if (serial != NULL) {
		serial_pair = tty0tty_get_pair(serial);
		if (serial_pair != NULL) {
			/* Index: open write_count cts_drop_count throttle_count
			 * Peer Index: open write_count cts_drop_count throttle_count */
			snprintf(message, 512, "%d: %d %d %d %d %d\n%d: %d %d %d %d %d\n",
					 serial->index, serial->open_count, serial->stats.write_count, serial->stats.cts_drop_count, serial->stats.throttle_count, serial->stats.throttle_drop_count,
					 serial_pair->index, serial_pair->open_count, serial_pair->stats.write_count, serial_pair->stats.cts_drop_count, serial_pair->stats.throttle_count, serial_pair->stats.throttle_drop_count);
		} else {
			sprintf(message, "Port pair not open\n");
		}
	} else {
		sprintf(message, "Port not open\n");
	}

	/* Make sure the message will fit in the user's buffer, truncate if it won't */
	len = (unsigned long)strlen(message) + 1;
	if (len > count) {
		len = count - 1;
	}

	/* NULL-terminate */
	message[len] = '\0';

	/* Copy the message out to user space */
	copy_to_user(buf, message, len);

	/* Update the file position */
	*f_pos += len;

	/* Return characters read */
	return len;
}

ssize_t stats_write (struct file* file, const char __user* buf, size_t count, loff_t* f_pos)
{
	char message[32];
	int len;
	int new_port;
	int rval = 0;

	/* Check the user's buffer size, truncate if it's too big */
	len = count;
	if (len >= sizeof(message)) {
		len = sizeof(message) - 1;
	}

	/* Copy the user's buffer into kernel space */
	copy_from_user(message, buf, len);

	/* NULL-terminate */
	message[len] = '\0';

	/* Grab the new TTY count */
	if (sscanf(message, "%d", &new_port) != 1) {
		return 0;
	}

	/* Validate */
	if (new_port < 0) {
		new_port = 0;
	}
	else if (new_port > MAX_DRIVER_TTY_COUNT) {
		new_port = MAX_DRIVER_TTY_COUNT;
	}

	g_tty_stat_port = new_port;

	return count;
}

/* File operations structure for the /proc file */
static const struct file_operations stat_ops = {
	.owner = THIS_MODULE,
	.open = tproc_open,
	.release = tproc_release,
	.read = stats_read,
	.write = stats_write
};

/* Procfs file for checking port stats */
int create_stat_file (void)
{
	/* Create the /proc file entry for this kernel module */
	g_proc_entry = proc_create(PROCFS_STATS_NAME, 0666, NULL, &stat_ops);
	return 0;
}

void remove_stat_file (void)
{
	/* Remove the /proc file entry for this kernel module */
	remove_proc_entry(PROCFS_STATS_NAME, NULL);
}
#endif /* CREATE_PROC_STAT_FILE */




static int __init tty0tty_init(void)
{
	int rval = 0;
	
	sema_init(&g_module_config_sem, 1);
	down(&g_module_config_sem);
	
	rval = tty0tty_open_ttys();
	if (rval) {
		goto exit;
	}

	rval = create_proc_file();
	if (rval) {
		goto exit;
	}

#ifdef CREATE_PROC_STAT_FILE
	rval = create_stat_file();
	if (rval) {
		goto exit;
	}
#endif /* CREATE_PROC_STAT_FILE */
	
exit:
	up(&g_module_config_sem);
	return rval;
}

static void __exit tty0tty_exit(void)
{
	down(&g_module_config_sem);
	
	remove_proc_file();
#ifdef CREATE_PROC_STAT_FILE
	remove_stat_file();
#endif /* CREATE_PROC_STAT_FILE */
	tty0tty_close_ttys();

	up(&g_module_config_sem);
}

module_init(tty0tty_init);
module_exit(tty0tty_exit);
