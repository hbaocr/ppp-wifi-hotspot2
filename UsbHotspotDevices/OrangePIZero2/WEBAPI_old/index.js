const cmd = require("./cmd");
const fs = require('fs');
const express = require('express');
const app = express();
const port = 5099;
const ip = "0.0.0.0";
const EventHdl = require("./server-sent-event");
const PppdMonitor = require("./pppd-monitor");
const index = fs.readFileSync("./web/index.html", 'utf8');
const pppd = new PppdMonitor();
pppd.exe();
//pppd.setTimeOut(60000);
const DEFAULT_PPPD_TIMEOUT_MS= 10*60*1000;/**10 min */
const DEFAULT_PPPD_MIN_TIMEOUT_MS= 3*60*1000;/**3 min */

app.use(express.json());

app.get('/', (req, res) => {
    //res.send('Hello from Dialup modem')
    res.send(index);
})
app.get('/events',(req,res)=>{
    const sse = new EventHdl(pppd.getdata);
    sse.handleSSE(req,res);
  });

app.get('/about', (req, res) => {
    res.send('Hello from Dialup modem')

})
app.post('/resetcounter',(req,res)=>{
    let timeout = req.body.timeout || DEFAULT_PPPD_TIMEOUT_MS;
    timeout=(timeout<DEFAULT_PPPD_MIN_TIMEOUT_MS)?DEFAULT_PPPD_MIN_TIMEOUT_MS:timeout;
    pppd.setTimeOut(timeout);
    res.send({
        status:'OK',
        timeout:timeout,
        desc:`minimum timeout is : ${DEFAULT_PPPD_MIN_TIMEOUT_MS}ms`
    })
})

app.post('/dial', async (req, res) => {
    try {

        let ppp_ip = await cmd.get_iface_ip("ppp0");
        if (ppp_ip.length > 0) {
            let detail = `ppp0 is existed and IP =${ppp_ip}`
            console.log(detail)

            res.send({
                status: 'EXISTED',
                detail: detail
            })


        } else {
            let modem_type = req.body.modem_type || cmd.HW_MODEM;
            let number = req.body.number || cmd.DEFAULT_NUMBER;
            let baudrate = req.body.baudrate || cmd.BAUD115200;
            let device = req.body.device || cmd.DEV_TTYACM0;
            
            let timeout = req.body.timeout || DEFAULT_PPPD_TIMEOUT_MS;
            timeout=(timeout<DEFAULT_PPPD_MIN_TIMEOUT_MS)?DEFAULT_PPPD_MIN_TIMEOUT_MS:timeout;
            pppd.setTimeOut(timeout);
            let resp=await cmd.dial_pppd(modem_type, number, baudrate, device);
            
            res.send(resp);
            
        }

    } catch (error) {
        res.send({
            status: 'ERR',
            detail: `${error}`
        })
    }

})

app.post('/hangup', async (req, res) => {

   await cmd.hangup_pppd();
    res.send({
        status: 'OK',
        detail: `Hanging Up. Please wait a bit, than checking the ppp ip.`
    })
    pppd.pauseCnt();
})

app.post('/reboot',  (req, res) => {
     cmd.reboot_modem();
     res.send({
         status: 'OK',
         detail: `Rebooting the system`
     })
 })

app.post('/get_ppp_ip', async (req, res) => {
    try {
        let ppp_ip = await cmd.get_iface_ip("ppp0");
        res.send({
            status: 'OK',
            detail: `ppp0 inet: ${ppp_ip}`
        })
    } catch (error) {
        res.send({
            status: 'ERR',
            detail: `${error}`
        })
    }
})


app.listen(port, ip, () => {
    console.log(`Example app listening on port ${port}`)
})