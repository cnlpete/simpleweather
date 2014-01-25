import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.simpleweather.WeatherInfo 1.0

import "../modules"

Page {
    id: page

    SilicaFlickable {

        id: root

        anchors.fill: parent

        flickableDirection: Flickable.VerticalFlick

        PullDownMenu {

            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("SettingPage.qml"), {currentSettings: settings}, PageStackAction.Animated);

                }



            }

            //            MenuItem {
            //                text: qsTr("Search by GPS")
            //                onClicked: {
            //                    weather.searchByGPS();
            //                }
            //            }
            MenuItem {
                text: qsTr("Manage cities")
                onClicked: {

                    pageStack.push(Qt.resolvedUrl("ManagementPage.qml"), {currentSettings: settings});
                }
            }

            MenuItem {
                text: qsTr("Add a city")
                onClicked: {
                    pageStack.push(searchPageComponent);
                }
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    weather.refresh();
                }
            }
        }

        Column {
            id: content

            width: parent.width
            height: parent.height-footer.height

            anchors.horizontalCenter: parent.horizontalCenter

            PageHeader {
                id: header
                title: qsTr("Current Weather")
            }

            Pager {
                id: cityPager

                anchors.horizontalCenter: parent.horizontalCenter

                model: weather.citiesModel

                delegate: Component {
                    WeatherDelegate {
                        height: cityPager.height
                        width: cityPager.width

                        contentHeight: height
                        contentWidth: width

                        cityData: modelData

                        Connections {
                            target: minutesTimer
                            onTriggered: {
                                updateTime();
                            }
                        }
                    }
                }

                isHorizontal: true
                hardEdges: true

                width: parent.width
                height: parent.height-header.height-cityIndicator.height

                startIndex: settings.allCities.indexOf(settings.currentCity)

                visible: !weather.downloading

                interactive: (cityPager.count > 1)

                placeholderText: qsTr("Add a city from the pulley menu")

                onIndexNowChanged: {
                    if(settings.currentCity !== settings.allCities[indexNow])
                    {
                        settings.currentCity = settings.allCities[indexNow];
                    }
                }

            }


            PagerHIndicator {
                id: cityIndicator
                pager: cityPager

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: Theme.paddingMedium

                height: page.height / 15

                indicatorRadius: height / 2

                visible: (cityPager.count > 1) && !weather.downloading

                z: 10
            }

        }

        Label {
            id: footer

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge

            color: Theme.highlightColor
            text: qsTr("Weather data by openweathermap.org")

        }

        BusyIndicator {
            anchors.centerIn: parent
            running: weather.downloading && Qt.application.active
            size: BusyIndicatorSize.Medium
        }

    }

    //swapping:
    property bool swapModeOn: false

    property int swapIndex: -1
    property int targetIndex: -1

    onSwapModeOnChanged: {
        if(!swapModeOn)
        {
            swapIndex = -1;
            targetIndex = -1;
        }
    }

    function initiateSwap()
    {
        settings.swapCities(swapIndex, targetIndex);
        swapModeOn = false;
        swapIndex = -1;
        targetIndex = -1;
    }

    function updateCityPagerFromCover()
    {
        var curInd = settings.allCities.indexOf(settings.currentCity);
        cityPager.showPage(curInd);
        cityPager.moveToPage(curInd);
    }

    onStatusChanged: {
        if(status === PageStatus.Deactivating)
        {

        }
        else if(status === PageStatus.Activating)
        {

            updateCityPagerFromCover();
        }
        else if(status === PageStatus.Active)
        {
            if(settings.forecastOn)
            {
                pageStack.pushAttached(Qt.resolvedUrl("ForecastPage.qml"),
                                       {city: cityPager.itemNow, currentSettings: settings});
            }

        }
        else
        {

        }
    }

}