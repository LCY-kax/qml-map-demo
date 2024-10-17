import QtQuick 2.12
import QtQuick.Window 2.12
import QtPositioning 5.14
import QtLocation 5.14
import QtQuick.Controls 1.0
import "./"

Window {
    id:window
    visible: true
    width: 1080
    height: 810
    title: qsTr("Hello World")

    Component.onCompleted: {
        for(var i in m_MapPlugin.availableServiceProviders){
            var it = m_MapPlugin.availableServiceProviders[i]
            console.log("Available Service Provider:", it)
        }
        console.log("locale---",m_MapPlugin.locales );
        console.log("m_MapPlugin.supportsRouting---",  m_MapPlugin.supportsRouting());
    }

    Map{
        id:map
        anchors.fill:parent
        plugin: Plugin{
            id:m_MapPlugin;
            name: "amap";
        }
        center: QtPositioning.coordinate( api.midLatitude,api.midLongitude)  // 设置地图中心点（latitude, longitude）
        zoomLevel: 12                // 设置缩放级别

        MapPolyline {
            id: routePolyline
            path: []  // 初始化为空路径
            line.width: 5
            line.color: "blue"
        }

        MapQuickItem {
            // 设置起点
            id:s1
            coordinate: QtPositioning.coordinate(api.midLatitude,api.midLongitude-0.02) // 标记的位置
            sourceItem:Image {
                width: 30
                height: 30
                source: "qrc:/marker.png" // 标记图片
            }
            //                Text {
            //                    text:"起点"
            //                    font.styleName: "bold"
            //                    font.pixelSize: 20
            //                }

            MouseArea {
                anchors.fill: parent
                drag.target: parent
            }
            property var step_num:0
            onCoordinateChanged: {
                if(coordinate && step_num <= api.polylines_path.length){

                    if( (haversine(convertCoordinates(coordinate),convertCoordinates(api.polylines_path[step_num])))<= 0.25255  ){
                        console.log( haversine(convertCoordinates(coordinate),convertCoordinates(api.polylines_path[step_num]))  );
                        api.polylines_path.shift();
                        console.log("path.length"+api.polylines_path.length)
//                        console.log("api.polylines_path=============" +api.polylines_path);
                        step_num++;
                    }
                    console.log("path.length"+api.polylines_path.length)
                    console.log( "重新计算路线"+haversine(convertCoordinates(coordinate),convertCoordinates(api.polylines_path[step_num-1]))  );
                    api.calculateRoute(convertCoordinates(s1.coordinate),convertCoordinates(s2.coordinate));
                }else{
                    step_num =0;
                    console.log("steps or start.coordinate error ")
                }

                routePolyline.path = api.polylines_path;
            }
        }
        MapQuickItem {
            // 设置终点
            id:s2
            coordinate:  QtPositioning.coordinate(api.midLatitude-0.02,api.midLongitude) // 标记的位置
            sourceItem:Image {
                width: 30
                height: 30

                source: "qrc:/marker.png" // 标记图片
            }
            //                Text {
            //                    text:"终点"
            //                    font.styleName: "bold"
            //                    font.pixelSize: 20
            //                }
            MouseArea {
                anchors.fill: parent
                drag.target: parent
            }

        }


        Text {
            anchors.top: s1.top
            anchors.topMargin: -4
            anchors.left: s1.left
            text:"起点"
            font.styleName: "bold"
            font.pixelSize: 20
        }
        Text {
            anchors.top: s2.top
            anchors.topMargin: -4
            anchors.left: s2.left
            text:"终点"
            font.styleName: "bold"
            font.pixelSize: 20
        }

        //           MapCircle {
        //               id:s1
        //               center:  QtPositioning.coordinate(28.74, 104.65)//route.path[0]  // 设置起点的圆形标记
        //               radius: 20000/((map.zoomLevel-11)*map.zoomLevel*map.zoomLevel)         // 半径
        //               border.width: 4
        //               border.color: "blue"
        //               color: "lightgray"
        //               MouseArea {
        //                   anchors.fill: parent
        //                   drag.target: parent
        //               }
        //               onCenterChanged: {
        ////                    api.calculateRoute(s1.center, s2.center);
        //                      routePolyline.path = [];
        //               }
        //           }

        //           MapCircle {
        //               id:s2
        //               center:  QtPositioning.coordinate(28.76, 104.65) //route.path[1]  // 设置终点的圆形标记
        //               radius: 20000/((map.zoomLevel-11)*map.zoomLevel*map.zoomLevel)
        //               border.width: 4
        //               border.color: "green"
        //               color: "lightgray"
        //               MouseArea {
        //                   anchors.fill: parent
        //                   drag.target: parent
        //               }
        //               onCenterChanged: {
        ////                    api.calculateRoute(s1.center, s2.center);
        //                   routePolyline.path = [];
        //               }
        //           }


        MapQuickItem {
            //当前位置
            id:self_p
            coordinate: QtPositioning.coordinate( api.midLatitude,api.midLongitude)// 标记的位置
            sourceItem:Image {
                width: 30
                height: 30
                source: "qrc:/marker.png" // 标记图片
            }
            MouseArea {
                anchors.fill: parent
                drag.target: parent
            }
        }
        Text {
            anchors.top: self_p.top
            anchors.topMargin: -4
            anchors.left: self_p.left
            text:"当前"
            font.styleName: "bold"
            font.pixelSize: 20
        }


        //        MapCircle {
        //            id: circle
        //            z:map.z+1
        //            center: QtPositioning.coordinate(28.75, 104.65)
        //            radius: 20000/((map.zoomLevel-11)*map.zoomLevel*map.zoomLevel)
        //            border.width: 5
        //            border.color: "red"
        //            MouseArea {
        //                anchors.fill: parent
        //                drag.target: parent
        //            }
        //        }
    }


    Row{
        Button{
            text: "放大+"
            onClicked: {
                map.zoomLevel++;
            }
        }
        Button{
            text: "缩小-"
            onClicked: {
                map.zoomLevel--;
            }
        }
        Button {
            text: "计算路线"
            onClicked: {
                // 这里调用 API 计算路线，例如：
                api.calculateRoute(convertCoordinates(s1.coordinate),convertCoordinates(s2.coordinate));

            }
        }
        Button {
            text: "取消路线"
            onClicked: {
                routePolyline.path = [];
                api.messageVisible =false;
                //                   console.log("!!!!"+s1.coordinate+"!!!"+s2.coordinate+"tr---"+convertCoordinates(s1.coordinate),convertCoordinates(s2.coordinate))
            }
        }
    }

    ApiUse{
        id:api
        anchors.fill: parent
    }


    // 将DMS转换为十进制度的函数
    function dmsToDecimal(degreeStr) {
        const parts = degreeStr.trim().split(" ");
        if (parts.length < 4) {
            return null; // 不合法的格式
        }

        const degrees = parseFloat(parts[0]);
        const minutes = parseFloat(parts[1]);
        const seconds = parseFloat(parts[2]);
        const direction = parts[3];

        let decimal = degrees + (minutes / 60) + (seconds / 3600);

        // 根据方向调整符号
        if (direction === 'S' || direction === 'W') {
            decimal *= -1;
        }

        return decimal.toFixed(5); // 保留五位小数
    }

    function convertCoordinates(input) {
        // 确保输入是字符串并去掉多余空格
        input = String(input).trim();
        const coords = input.split(",");
        if (coords.length !== 2 && coords.length !== 3) {
            return "Invalid format"; // 不合法的输入
        }

        const latitude = dmsToDecimal(coords[0]);
        const longitude = dmsToDecimal(coords[1]);
        // const height = dmsToDecimal(coords[2]); 忽略第三个的高度参数

        if (latitude === null || longitude === null) {
            return "Invalid DMS format"; // DMS格式不合法
        }

        return longitude + "," + latitude; // 返回转换后的坐标
    }

    function haversine(lon1_lat1, lon2_lat2) {
        var lon1,lon2,lat1,lat2
        const coords1 = lon1_lat1.split(",");
        const coords2 = lon2_lat2.split(",");
        lon1 =coords1[0];
        lat1 =coords1[1];
        lon2 =coords2[0];
        lat2 =coords2[1];

        var deg2rad = Math.PI / 180;
        var dlon = (lon2 - lon1) * deg2rad;
        var dlat = (lat2 - lat1) * deg2rad;

        var a = Math.sin(dlat / 2) * Math.sin(dlat / 2) +
                Math.cos(lat1 * deg2rad) * Math.cos(lat2 * deg2rad) *
                Math.sin(dlon / 2) * Math.sin(dlon / 2);
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        var r = 6371; // 地球半径，单位为公里
        var distance = c * r;
        return distance;
    }


}
