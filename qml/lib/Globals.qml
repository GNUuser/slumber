import QtQuick 2.0

import QtMultimedia 5.0

Rectangle {
    property alias options: options
    property alias sleepTimer: sleepTimer
//    property alias appstate: appstate
    property alias accelerometerTrigger: accelerometerTrigger

    //    property alias volume: volume
    property alias fadeOutSound: fadeOutSound
    //    property alias audiofadeout: audiofadeout
    property alias actionPauseKodi: actionPauseKodi
    property alias actionPauseVLC: actionPauseVLC

    PersistentObject {
        id: options
        objectName: 'options'
        doPersist: true

        //milliseconds:
        property int skipDurationSmall: 10000 //10s
        property int skipDurationNormal: 60000 //1m

        property real playbackRate:1


        //timer
        property bool timerEnabled: false
        property bool timerInhibitScreensaverEnabled: false

        property int timerSeconds: 900
        property bool timerMotionEnabled:false
        property bool timerWaveMotionEnabled:false
        property real timerMotionThreshold: 0

        property bool timerPauseEnabled: true

        property bool timerDisableBluetoothEnabled: false

        property bool timerKodiPauseEnabled: false
        property string timerKodiPauseHost: ''
        property string timerKodiPauseUser: ''
        property string timerKodiPausePassword: ''

        property bool timerVLCPauseEnabled: false
        property string timerVLCPauseHost: ''
        property string timerVLCPauseUser: ''
        property string timerVLCPausePassword: ''

        property bool timerFadeEnabled: true // todo reimplement fadeout volume
        property bool timerFadeResetEnabled: true //todo reset volume afterwards

        property bool timerFadeSoundEffectEnabled: true
        property string timerFadeSoundEffectFile: 'cassette-noise'
        property bool timerFadeVisualEffectEnabled: false



        property real timerFadeSoundEffectVolume: 0.5

        property real viewDarkenMainScreenAmount: 0.7
        property bool viewDarkenMainSceen:false
        //            property bool viewDarkenMainSceenOnlyWhenRunning:true
        property bool viewTimeFormatShort:false
        property bool viewActiveIndicatorEnabled: true
        property bool viewActiveOptionsButtonEnabled: false


        //cover options
        property bool appCoverAnimateEnabled: true

    }

//    PersistentObject {
//        id: appstate
//        objectName: 'appstate'
//        doPersist: true

//        //timer
//        property bool timerRunning: false

//    }

    ScreenBlank {
        enabled: options.timerInhibitScreensaverEnabled && sleepTimer.running
    }

    AccelerometerTrigger {
        id: accelerometerTrigger
        paused: false
        triggerThreshold: options.timerMotionThreshold
        active: options.timerMotionEnabled && options.timerMotionThreshold && sleepTimer.running && !paused
        proximityActive: options.timerWaveMotionEnabled && sleepTimer.running
        onTriggered: function(){
            sleepTimer.restart()
        }
    }

    Item {
        id:actionPauseByPlayingVoid
        property var pause: function(){
            playbackEl.play()
        }
        Audio {
            id: playbackEl
            autoLoad: true
            source: '../assets/sound/void.mp3'
        }
    }
    DBusPauseMediaplayers {
        id:actionPauseByDbus
    }

    //    ActionLockScreen{
    //        id: actionLockScreen
    //        enabled: options.timerLockScreenEnabled
    //    }
    ActionDisableBluetooth {
        id: actionDisableBluetooth
        enabled: options.timerDisableBluetoothEnabled
    }

    ActionNetworkKodi{
        id: actionPauseKodi
        enabled: options.timerKodiPauseEnabled
        host: options.timerKodiPauseHost
        user: options.timerKodiPauseUser
        password: options.timerKodiPausePassword
    }

    ActionNetworkVLC{
        id: actionPauseVLC
        enabled: options.timerVLCPauseEnabled
        host: options.timerVLCPauseHost
        user: options.timerVLCPauseUser
        password: options.timerVLCPausePassword
    }
//    VolumeFade {
//        id: volumeFade
//    }

//        Component.onCompleted: {
//            volumeFade.start()
    //actionDisableBluetooth.pause()
    //        actionLockScreen.pause()
//        }

    CountDownTimer {
        id: sleepTimer
        interval: options.timerSeconds * 1000
        enabled: true
        property double targetVolume: 1
        triggerBeforeIntervalDuration: 10000
        triggerBeforeInterval: function(){
            if(options.timerFadeEnabled) {
                if(options.timerFadeSoundEffectEnabled) {
                    fadeOutSound.play();
                }
            }
        }
        onTriggered:function() {
            console.log('sleep timer fired!');
            //            actionLockScreen.pause()
            if(options.timerPauseEnabled) {
                actionPauseByDbus.pause()
                //gpodder, maybe others
                actionPauseByPlayingVoid.pause()
            }
            actionDisableBluetooth.pause()
            actionPauseKodi.action(function(o, success){
                console.log('Kodi: success', success)
            });
            actionPauseVLC.action(function(o, success){
                console.log('VLC: success', success)
            });

            sleepTimer.stop()
        }
        onReset:function(){

            fadeOutSound.stop();
        }

        Item {
            id: fadeOutSound
            property string file: options.timerFadeSoundEffectFile
            property var effect:null
            property alias volume: options.timerFadeSoundEffectVolume

            //            property alias playing: effect.playing
            onFileChanged: {
                stop()
                if(file === "cassette-noise") {
                    effect = fadeOutSoundCassette;
                } else if(file === "clock-ticking") {
                    effect = fadeOutSoundTicking;
                } else if(file === "sea-waves") {
                    effect = fadeOutSoundSea;
                }
                if(effect){
                    effect.volume = volume;
                }
            }
            onVolumeChanged: {
                if(effect){
                    effect.volume = volume;
                }
            }

            function play(){
                stop()
                if(effect){
                    effect.play()
                }
            }
            function stop(){
                fadeOutSoundCassette.stop()
                fadeOutSoundTicking.stop()
                fadeOutSoundSea.stop()
            }


            SoundEffect {
                id:fadeOutSoundCassette
                source: '../assets/sound/cassette-noise.wav'
                volume: options.timerFadeSoundEffectVolume
                onPlayingChanged: {
                    if(!playing) { accelerometerTrigger.paused = false}
                }
            }


            SoundEffect {
                id:fadeOutSoundTicking
                source: '../assets/sound/clock-ticking.wav'
                volume: options.timerFadeSoundEffectVolume
                onPlayingChanged: {
                    if(!playing) { accelerometerTrigger.paused = false}
                }
            }

            SoundEffect {
                id:fadeOutSoundSea
                source: '../assets/sound/sea-waves.wav'
                volume: options.timerFadeSoundEffectVolume
                onPlayingChanged: {
                    if(!playing) { accelerometerTrigger.paused = false}
                }
            }


        }



    }


}

