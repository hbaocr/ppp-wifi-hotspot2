//https://masteringjs.io/tutorials/express/server-sent-events

class ServerSentEvent {
    constructor(_getJsonData=null,setInterval=1000) {
        this.sseInterval = setInterval;
        this.getdata=_getJsonData;
    }
    handleSSE(req, res) {
        console.log('Got /events');
        res.set({
            'Cache-Control': 'no-cache',
            'Content-Type': 'text/event-stream',
            'Connection': 'keep-alive'
        });
        res.flushHeaders();

        // Tell the client to retry every 10 seconds if connectivity is lost
        res.write('retry: 10000\n\n');
        let count = 0;
        //res.bind(this);
        res.on('close', function () {
            console.log(`${sseHdl} close`);
            clearInterval(sseHdl); //destroy previous 
        })
        let sseHdl = setInterval(() => {
           
            let data={
                seq:count++,
                msg:{}
            }
            if(this.getdata !=null){
                data.msg= this.getdata();
            }
            // Emit an SSE that contains the current 'count' as a string
            res.write(`data: ${JSON.stringify(data)}\n\n`);

        }, this.sseInterval);
    }

}
module.exports = ServerSentEvent;

