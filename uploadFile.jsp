
<!DOCTYPE html>


<html>
<head>
<link href="/webjars/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet">
    
    <script src="/webjars/jquery/3.1.0/jquery.min.js"></script>
    <script src="/webjars/sockjs-client/1.0.2/sockjs.min.js"></script>
    <script src="/webjars/stomp-websocket/2.3.3/stomp.min.js"></script>
    <script>
    var stompClient = null;

    function setConnected(connected) {
        $("#files").prop("disabled", connected);
        
        if (connected) {
            $("#conversation").show();
        }
        else {
            $("#conversation").hide();
        }
        $("#greetings").html("");
    }

    function connect() {
        var socket = new SockJS('/chat');
        stompClient = Stomp.over(socket);
        stompClient.connect({}, function (frame) {
            setConnected(true);
            console.log('Connected: ' + frame);
            stompClient.subscribe('/topic/messages', function (greeting) {
                showGreeting(JSON.parse(greeting.body).content);
            });
        });
    }

    function disconnect() {
        if (stompClient !== null) {
            stompClient.disconnect();
        }
        setConnected(false);
        console.log("Disconnected");
    }

    function sendName() {
        stompClient.send("/app/hello", {}, JSON.stringify({'name': $("#name").val()}));
    }

    function showGreeting(message) {
        $("#greetings").append("<tr><td>" + message + "</td></tr>");
    }


    
    $(function () {
    	 $("#form").on('submit', function (e) {
             e.preventDefault();
         });
        $( "#files" ).click(function() { connect(); });
       
    });
    </script>
<script>
    var totalFileLength, totalUploaded, fileCount, filesUploaded;
 
    //To log everything on console
    function debug(s) {
        var debug = document.getElementById('debug');
        if (debug) {
            debug.innerHTML = debug.innerHTML + '<br/>' + s;
        }
    }
 
    //Will be called when upload is completed
    function onUploadComplete(e) {
        totalUploaded += document.getElementById('files').files[filesUploaded].size;
        filesUploaded++;
        debug('complete ' + filesUploaded + " of " + fileCount);
        debug('totalUploaded: ' + totalUploaded);
        if (filesUploaded < fileCount) {
            uploadNext();
        } else {
            var bar = document.getElementById('bar');
            bar.style.width = '100%';
            bar.innerHTML = '100% complete';
            alert('Finished uploading file(s)');
        }
    }
 
    //Will be called when user select the files in file control
    function onFileSelect(e) {
        var files = e.target.files; // FileList object
        var output = [];
        fileCount = files.length;
        totalFileLength = 0;
        for (var i = 0; i < fileCount; i++) {
            var file = files[i];
            output.push(file.name, ' (', file.size, ' bytes, ', file.lastModifiedDate.toLocaleDateString(), ')');
            output.push('<br/>');
            debug('add ' + file.size);
            totalFileLength += file.size;
        }
        document.getElementById('selectedFiles').innerHTML = output.join('');
        debug('totalFileLength:' + totalFileLength);
    }
 
    //This will continueously update the progress bar
    function onUploadProgress(e) {
        if (e.lengthComputable) {
            var percentComplete = parseInt((e.loaded + totalUploaded) * 100 / totalFileLength);
            var bar = document.getElementById('bar');
            bar.style.width = percentComplete + '%';
            bar.innerHTML = percentComplete + ' % complete';
        } else {
            debug('unable to compute');
        }
    }
 
    //the Ouchhh !! moments will be captured here
    function onUploadFailed(e) {
        alert("Error uploading file");
    }
 
    //Pick the next file in queue and upload it to remote server
    function uploadNext() {
        var xhr = new XMLHttpRequest();
        var fd = new FormData();
        var file = document.getElementById('files').files[filesUploaded];
        fd.append("file", file);
        xhr.upload.addEventListener("progress", onUploadProgress, false);
        xhr.addEventListener("load", onUploadComplete, false);
        xhr.addEventListener("error", onUploadFailed, false);
        xhr.open("POST", "files");
        debug('uploading ' + file.name);
        xhr.send(fd);
    }
 
    //Let's begin the upload process
    function startUpload() {
        totalUploaded = filesUploaded = 0;
        uploadNext();
    }
 
    //Event listeners for button clicks
    window.onload = function() {
        document.getElementById('files').addEventListener('change', onFileSelect, false);
        document.getElementById('uploadButton').addEventListener('click', startUpload, false);
    }
</script>
</head>
<body>
    <div style="width:55%"> 
        <h1>HTML5 Ajax Multi-file Upload With Progress Bar</h1>
        <div id='progressBar' style='height: 20px; border: 2px solid green; margin-bottom: 20px'>
            <div id='bar' style='height: 100%; background: #33dd33; width: 0%'>
            </div>
        </div>
        <form id="form" style="margin-bottom: 20px">
            <input type="file" id="files" multiple style="margin-bottom: 20px"/><br/>
            <output id="selectedFiles"></output>
            <input id="uploadButton" type="button" value="Upload" style="margin-top: 20px"/>
        </form>
        <div id='debug' style='height: 100px; border: 2px solid #ccc; overflow: auto'></div>
        
         <div class="row">
        <div class="col-md-12">
            <table id="conversation" class="table table-striped">
                <thead>
                <tr>
                    <th>Greetings</th>
                </tr>
                </thead>
                <tbody id="greetings">
                </tbody>
            </table>
            </div></div>
    </div>
</body>
</html>