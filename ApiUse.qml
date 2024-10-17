import QtQuick 2.0
import QtPositioning 5.14
import QtLocation 5.14
import QtQuick.Controls 1.0

Item {
    id:api
    property  var jsonResponse :JSON.parse("{}");
    property  var jsonResponse2 :'{"route":{"paths":[{"distance":"0","duration":0,"strategy":"0","tolls":"0"}]}}';
    property  var dataString
    property  var midLongitude:104.62961555000001
    property var midLatitude:28.77059144
    property var params :({
                              ip: ips,
                              key: keys
                          });
    property bool dialogVisible:false
    property bool messageVisible:false
    property var steps:0

    property var polylines_path:[]
    // 导航信息文本
    Column {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        visible:messageVisible
         Text {id: message1; font.pointSize: 24; text: "行驶距离"+(JSON.parse(jsonResponse2).route.paths[0].distance/1000).toFixed(2)+"千米" /*"Normal" */}
         Text {id: message2;  font.pointSize: 24; text: "预计行驶时间"+(JSON.parse(jsonResponse2).route.paths[0].duration/60).toFixed(2)+"分钟" /*"Raised"*/; style: Text.Raised; styleColor: "#AAAAAA" }
         Text {id: message3;  font.pointSize: 24; text: "当前导航策略:"+JSON.parse(jsonResponse2).route.paths[0].strategy/*"Outline"*/;style: Text.Outline; styleColor: "red" }
         Text {id: message4;  font.pointSize: 24; text: "导航道路收费:"+JSON.parse(jsonResponse2).route.paths[0].tolls+"元"/*"Sunken"*/; style: Text.Sunken; styleColor: "#AAAAAA" }
     }

    // 错误信息文本
    Text {
        id: errorDialog
        text: "IP 错误"
        visible: dialogVisible
        anchors.centerIn: parent
        font.pixelSize: 32
        color: "red"
        font.bold: true
    }

    // 定时器，用于隐藏错误信息
    Timer {
        id: hideTimer
        interval: 3000  // 2秒
        running: false
        repeat: false
        onTriggered: {
            dialogVisible = false;  // 隐藏错误信息
        }
    }

    Row{
        anchors.bottom: parent.bottom
        TextField{
            width: 200
            placeholderText:"Enter your ip"
            onEditingFinished: {
                params.ip =text;
                if(params.ip && isValidIP(params.ip)){
                    console.log("Text changed to:", params.ip);
                }else{
                     console.log("ip error");
                    params.ip = ips;
                    dialogVisible = true;
                    hideTimer.start();
                }
            }
        }
        Button {
            //        anchors.bottom: parent.bottom
            text: "当前位置"
            onClicked: {
                const baseUrl = "https://restapi.amap.com/v3/ip";
                //            var jsonResponse =JSON.parse("{}");
                const url = `${baseUrl}?ip=${params.ip.toString()}&key=${params.key.toString()}&output=JSON`;
                console.log("url: " +url);
                var xhr = new XMLHttpRequest();

                xhr.open("GET", url);

                // xhr.open("GET", "https://restapi.amap.com/v3/ip"+"?ip="+ips+"&key="+keys); // 替换为您的API URL
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        if (xhr.status === 200) {
                            console.log("Response: " + xhr.responseText);
                            // 处理响应数据
                            jsonResponse = xhr.responseText;
                            // console.log("------JSON.parse()",JSON.parse(jsonResponse).rectangle); // 直接查看对象
                            calculateMidNum(JSON.parse(jsonResponse).rectangle);
                        } else {
                            console.error("Error: " + xhr.status);
                        }
                    }
                };
                xhr.send();
            }
        }
    }
    function calculateMidNum(dataString){

        // 将字符串按分号分割成数组
        var coordinates = dataString.split(";");

        // 将第一个和第二个坐标按逗号分割
        var firstCoord = coordinates[0].split(",");
        var secondCoord = coordinates[1].split(",");

        // 获取经度和纬度
        var longitude1 = parseFloat(firstCoord[0]);
        var latitude1 = parseFloat(firstCoord[1]);
        var longitude2 = parseFloat(secondCoord[0]);
        var latitude2 = parseFloat(secondCoord[1]);

        // 计算中间值
        midLongitude = (longitude1 + longitude2) / 2;
        midLatitude = (latitude1 + latitude2) / 2;
        console.log("Midpoint:", midLongitude, midLatitude);
    }

    function isValidIP(ip) {
        // 正则表达式用于匹配 IPv4 地址
        const ipPattern = /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
        return ipPattern.test(ip);
    }


    //路线计算
    function calculateRoute(start, end) {
        const baseUrl = "https://restapi.amap.com/v3/direction/driving";
        const url = `${baseUrl}?origin=${start}&destination=${end}&extensions=all&key=${params.key.toString()}&output=JSON`;
        console.log("url: " +url);
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
//                    console.log("Response2: " + xhr.responseText+"-\n -\n-\n");
                    jsonResponse2 = xhr.responseText;
//                    console.log("jsonResponse2-duration"+ (JSON.parse(jsonResponse2).route.paths[0].duration))
//                    console.log("jsonResponse2"+ (JSON.parse(jsonResponse2).route.paths[0].duration/60).toFixed(2))
                    console.log("JSON.parse(jsonResponse2).route.paths[0].steps---"+(JSON.parse(jsonResponse2).route.paths[0].steps.length))
                    steps= (JSON.parse(jsonResponse2).route.paths[0].steps.length);
                    polylines();

                    messageVisible=true;
                } else {
                    console.error("Error: " + xhr.status);
                }
            }
        };
        xhr.send();

//  paths[i]  strategy:
//        0，速度优先，此路线不一定距离最短
//        1，费用优先，不走收费路段，且耗时最少的路线
//        2，距离优先，仅走距离最短的路线，但是可能存在穿越小路/小区的情况
//        3，速度优先，不走快速路，例如京通快速路（因为策略迭代，建议使用13）
//        4，躲避拥堵，但是可能会存在绕路的情况，耗时可能较长
//        5，多策略（同时使用速度优先、费用优先、距离优先三个策略计算路径）。
//        其中必须说明，就算使用三个策略算路，会根据路况不固定的返回一~三条路径规划信息。
//        6，速度优先，不走高速，但是不排除走其余收费路段
//        7，费用优先，不走高速且避免所有收费路段
//        8，躲避拥堵和收费，可能存在走高速的情况，并且考虑路况不走拥堵路线，但有可能存在绕路和时间较长
//        9，躲避拥堵和收费，不走高速
    }
    function polylines(){
        polylines_path=[]
        polylines_path.push(s1.coordinate);
        for (var i = 0; i < JSON.parse(jsonResponse2).route.paths[0].steps.length; i++) {
            var points = JSON.parse(jsonResponse2).route.paths[0].steps[i].polyline.split(";")
//            console.log("points----"+points);
            for (var j = 0; j < points.length; j++) {
                var coordinates = points[j].split(",")
                polylines_path.push(QtPositioning.coordinate(parseFloat(coordinates[1]), parseFloat(coordinates[0])))
            }
        }
        polylines_path.push(s2.coordinate);

        // 更新多段线的路径
//        console.log("path"+path);
        routePolyline.path = polylines_path;
    }

    Component.onCompleted: {

    }
}
