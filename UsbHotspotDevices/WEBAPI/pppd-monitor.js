const cmd = require("./cmd");

const STATUS_CONNECTED = "Connected";
const STATUS_HANGUP = "HangUp";
const STATUS_DIALING = "Dailing";


class PppdMonitor {
    constructor(interval = 1000, maxMs = 15 * 60 * 1000) {
        this.interval = interval;
        this.infor = {
            Cntactive:false,
            maxCnt: maxMs,
            status: STATUS_HANGUP,
            cnt: maxMs,
            ip:"",
            msg: ""
        }
        this.getdata = this.getdata.bind(this);
        this.exe = this.exe.bind(this);
        this.stop = this.stop.bind(this);
        this.setTimeOut = this.setTimeOut.bind(this);
        this.pauseCnt=this.pauseCnt.bind(this);
    }
    
    /* set time to call hangup function */
    setTimeOut(_maxMs = 0) {
        this.infor.Cntactive = true;
        if (_maxMs > 0) {
            this.infor.maxCnt = _maxMs;
            this.infor.cnt = _maxMs;
        } else {
            this.infor.maxCnt = this.infor.maxCnt;
            this.infor.cnt = this.infor.maxCnt;
        }
    }

    exe() {
        this.intervalHdl = setInterval(async () => {

            try {
                let ppp_ip = await cmd.get_iface_ip("ppp0");
                let pppd_pid = await cmd.get_pppd_pid();

                //console.log(`ip=${ppp_ip}, pppd_pid=${pppd_pid}`); 
        
                if (ppp_ip.length > 0) {
                    this.infor.status = STATUS_CONNECTED;
                    this.infor.ip = ppp_ip.trim();
                    this.infor.msg = "PPP is connected. ";
                } else {
                   
                    if (pppd_pid > 0) {
                        this.infor.status = STATUS_DIALING;
                        this.infor.ip = "";
                        this.infor.msg = `PPP is dialing. `;
                    } else {
                        this.infor.status = STATUS_HANGUP;
                        this.infor.ip = "";
                        this.infor.msg = `PPP hangup. `;
                    }
                }
            } catch (err) {
                console.error(err);
            }

            if(this.infor.Cntactive){
                
                if( this.infor.cnt <0){
                    this.infor.Cntactive= false;
                    this.infor.cnt = this.infor.maxCnt;
                    await cmd.hangup_pppd();
                }
                this.infor.cnt = this.infor.cnt - this.interval;
                if(this.infor.status != STATUS_HANGUP){
                    let timeoutMsg=`The modem will be hang up after ${this.infor.cnt/1000} sec. Please reset the counter to keep the connection before timeout`
                    this.infor.msg = this.infor.msg+timeoutMsg;
                }
             
            }else{
                this.infor.cnt = this.infor.maxCnt;
            }

            //console.log(this.infor);
        }, this.interval)
    }
    stop() {
        if (this.intervalHdl) {
            clearInterval(this.intervalHdl);
            this.infor.cnt = this.infor.maxCnt;
            this.infor.msg = "";
        }
    }
    pauseCnt(){
        this.infor.Cntactive= false;
        this.infor.cnt = this.infor.maxCnt;
    }
    getdata() {
        //return {cnt:this.infor.cnt,status:this.infor.status,msg:this.infor.msg}
        return this.infor;
    }

}
module.exports = PppdMonitor;