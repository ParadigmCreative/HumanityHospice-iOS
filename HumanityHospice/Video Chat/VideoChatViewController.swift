//
//  VideoChatViewController.swift
//  Agora iOS Tutorial
//
//  Created by James Fang on 7/14/16.
//  Copyright © 2016 Agora.io. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit
import CallKit

protocol VideoChatDelegate {
    func didFinishCall()
}

class VideoChatViewController: UIViewController, Storyboarded {
    @IBOutlet weak var localVideo: UIView!              // Tutorial Step 3
    @IBOutlet weak var remoteVideo: UIView!             // Tutorial Step 5
    @IBOutlet weak var controlButtons: UIView!
    @IBOutlet weak var remoteVideoMutedIndicator: UIImageView!
    @IBOutlet weak var localVideoMutedBg: UIImageView!
    @IBOutlet weak var localVideoMutedIndicator: UIImageView!

    var agoraKit: AgoraRtcEngineKit!                    // Tutorial Step 1
    
    var coordinator: NurseCoordinator?
    
    var uuid: UInt!
    var sessionID: String!
    var call: Call?
    var shouldStartTimer: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Log.s("STARTING SETUP OF VIDEO FEED")
        setupButtons()              // Tutorial Step 8
        hideVideoMuted()            // Tutorial Step 10
        initializeAgoraEngine()     // Tutorial Step 1
        setupVideo()                // Tutorial Step 2
        setupLocalVideo()           // Tutorial Step 3
        joinChannel()               // Tutorial Step 4
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { (granted) in
            Log.i("Can use mic: \(granted)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        Log.d("Deint")
    }
    
    // Tutorial Step 1
    func initializeAgoraEngine() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppID, delegate: self)
        agoraKit.delegate = self
    }

    // Tutorial Step 2
    func setupVideo() {
        agoraKit.enableVideo()  // Default mode is disableVideo
        agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360,
                                                                             frameRate: .fps15,
                                                                             bitrate: AgoraVideoBitrateStandard,
                                                                             orientationMode: .adaptative))
    }
    
    // Tutorial Step 3
    func setupLocalVideo() {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.view = localVideo
        videoCanvas.renderMode = .hidden
        agoraKit.setupLocalVideo(videoCanvas)
    }
    
    // Tutorial Step 4
    func joinChannel() {
        agoraKit.setEnableSpeakerphone(true)
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        
        agoraKit.joinChannel(byToken: nil, channelId: sessionID, info:nil, uid: self.uuid) {[weak self] (sid, uid, elapsed) -> Void in
            if let weakSelf = self {
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
    }
    
    // Tutorial Step 6
    @IBAction func didClickHangUpButton(_ sender: UIButton) {
        leaveChannel()
        if AppSettings.userType == .Staff {
            self.coordinator!.navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func leaveChannel() {
        let result = agoraKit.leaveChannel { (stats) in
            Log.s(stats)
        }
        Log.s("Leave Result: \(result)")
        hideControlButtons()   // Tutorial Step 8
        UIApplication.shared.isIdleTimerDisabled = false
        remoteVideo.removeFromSuperview()
        localVideo.removeFromSuperview()
        
    }
    
    // Tutorial Step 8
    func setupButtons() {
        perform(#selector(hideControlButtons), with:nil, afterDelay:8)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(VideoChatViewController.ViewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isUserInteractionEnabled = true
    }

    @objc func hideControlButtons() {
        controlButtons.isHidden = true
    }
    
    @objc func ViewTapped() {
        if (controlButtons.isHidden) {
            controlButtons.isHidden = false;
            perform(#selector(hideControlButtons), with:nil, afterDelay:8)
        }
    }
    
    func resetHideButtonsTimer() {
        VideoChatViewController.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(hideControlButtons), with:nil, afterDelay:8)
    }
    
    // Tutorial Step 9
    @IBAction func didClickMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.muteLocalAudioStream(sender.isSelected)
        resetHideButtonsTimer()
    }
    
    // Tutorial Step 10
    @IBAction func didClickVideoMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.muteLocalVideoStream(sender.isSelected)
        localVideo.isHidden = sender.isSelected
        localVideoMutedBg.isHidden = !sender.isSelected
        localVideoMutedIndicator.isHidden = !sender.isSelected
        resetHideButtonsTimer()
    }
    
    func hideVideoMuted() {
        remoteVideoMutedIndicator.isHidden = true
        localVideoMutedBg.isHidden = true
        localVideoMutedIndicator.isHidden = true
    }
    
    // Tutorial Step 11
    @IBAction func didClickSwitchCameraButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.switchCamera()
        resetHideButtonsTimer()
    }
}

extension VideoChatViewController: AgoraRtcEngineDelegate {
    // Tutorial Step 5
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid:UInt, size:CGSize, elapsed:Int) {
        if (remoteVideo.isHidden) {
            remoteVideo.isHidden = false
        }
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = remoteVideo
        videoCanvas.renderMode = .adaptive
        agoraKit.setupRemoteVideo(videoCanvas)
    }
    
    // Tutorial Step 7
    internal func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:UInt, reason:AgoraUserOfflineReason) {
        self.remoteVideo.isHidden = true
    }
    
    // Tutorial Step 10
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted:Bool, byUid:UInt) {
        remoteVideo.isHidden = muted
        remoteVideoMutedIndicator.isHidden = !muted
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        Log.d(channel, uid)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        Log.s("Successful leave")
        Log.s(stats)
    }
    
}


