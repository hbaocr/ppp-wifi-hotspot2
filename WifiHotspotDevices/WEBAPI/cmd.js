const fs = require('fs');
const os_cmd = require('child_process');
const HW_MODEM = 1
const SAMS_MODEM = 0
const DEFAULT_NUMBER = 8000
const BAUD115200 = 115200
const DEV_TTYACM0 = "ttyACM0"

function dial_pppd(modem_type = HW_MODEM, number = DEFAULT_NUMBER, baudrdate = BAUD115200, device = DEV_TTYACM0) {
    return new Promise(async (resolve,reject)=>{

        let cmd_para = ` ${modem_type} ${number} ${baudrdate} ${device} `;
        let pppd_pid = await get_pppd_pid();
        if(pppd_pid>0){
            let msg=`PPPD is dailing(pid= ${pppd_pid}). Please call /hangup to start another session`;
            console.log(msg)
            resolve({
                status:'DAILING',
                detail: msg
            })

        } else{
            let cmd = `sudo ./ppp_dial.sh ${cmd_para}`
            cmd = `cd bin && ${cmd}`;
            let cmd_data=''
            let child =  os_cmd.exec(cmd)
            child.stdout.on('data', function(data) {

                cmd_data = cmd_data+data.toString()
                console.log(data.toString());
                if(cmd_data.search(`remote IP address`)>0){

                    resolve({
                        status:'CONNECTED',
                        detail: 'Established pppd with server.'
                    })
                }

            })

        }


    })

}

function hangup_pppd() {
    return new Promise((resolved, reject) => {
    let cmd = `cd bin && sudo ./stop_pppd.sh`
    //console.log(cmd);
    os_cmd.exec(cmd, function (error, stdout, stderr) {
        if (error) {
            resolved(error);
            console.log(stderr);
        } else {
            resolved(stdout);
        }
    });})
}


function get_iface_ip(iface_name) {
    return new Promise((resolved, reject) => {
        let cmd = `ifconfig ${iface_name} |grep "inet " | awk '{print $2}'`
        //console.log(cmd);
        os_cmd.exec(cmd, function (error, stdout, stderr) {
            if (error) {
                reject(stderr);
            } else {
                resolved(stdout.toString().trim());
            }
        });
    })
}

// if return >0 ==> pppd is running
function get_pppd_pid() {
    let cmd = `sudo pidof pppd`;
    return new Promise((resolved, reject) => {
        //console.log(cmd);
        os_cmd.exec(cmd, function (error, stdout, stderr) {
            let pppd_pid =-2;
            if (error) {
                //console.log(error);
                pppd_pid =-1;
            } else {
                //console.log(stdout);
                try {
                    pppd_pid = parseInt(stdout);
                } catch (error) {
                    console.log(error)
                }
                if(pppd_pid==NaN){
                    pppd_pid=0;
                }
            }
            resolved(pppd_pid);
            //console.log(pppd_pid);
        });
    });
}

// if return >0 ==> pppd is running
function reboot_modem() {
    let cmd = `sudo reboot`;
    return new Promise((resolved, reject) => {
        //console.log(cmd);
        os_cmd.exec(cmd, function (error, stdout, stderr) {
            let pppd_pid =-2;
            if (error) {
                //console.log(error);
                pppd_pid =-1;
            } else {
                //console.log(stdout);
                try {
                    pppd_pid = parseInt(stdout);
                } catch (error) {
                    console.log(error)
                }
                if(pppd_pid==NaN){
                    pppd_pid=0;
                }
            }
            resolved(pppd_pid);
            //console.log(pppd_pid);
        });
    });
}

module.exports={
    HW_MODEM,
    SAMS_MODEM,
    DEFAULT_NUMBER,
    BAUD115200,
    DEV_TTYACM0,
    dial_pppd,
    hangup_pppd,
    get_iface_ip,
    get_pppd_pid,
    reboot_modem
}



// async function test(){
//     try {
//         console.log("testst")
//         let aa = await get_iface_ip("ppp0");
//         console.log(aa.length)
//         console.log("end")
//     } catch (error) {
//         console.log(`error`)
//     }

// }

// test()
// let out=`rcvd [IPCP ConfAck id=0x2 <compress VJ 0f 01> <addr 10.9.0.94>]

// Script /etc/ppp/ip-pre-up started (pid 44441)

// Script /etc/ppp/ip-pre-up finished (pid 44441), status = 0x0

// replacing old default route to eth0 [10.66.77.1]
// del old default route ioctl(SIOCDELRT): No such process(3)
// local  IP address 10.9.0.94
// remote IP address 10.9.0.93

// Script /etc/ppp/ip-up started (pid 44444)

// Script /etc/ppp/ip-up finished (pid 44444), status = 0x0`
// let aa=out.search(`remote IP address`)
// console.log(aa)
