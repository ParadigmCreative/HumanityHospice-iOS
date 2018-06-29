//
//  Constants.swift
//  HumanityHospice
//
//  Created by App Center on 6/28/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

class co {
    public static let journal = Journals()
    public static let encouragementBoard = EncouragementBoard()
    public static let photoAlbum = PhotoAlbumStr()
    public static let inviteCodes = InviteCodes()
    public static let profilePictures = ProfilePictures()
    public static let patient = Patient()
    public static let reader = Reader()
    public static let family = Family()
}

struct Journals {
    let Journals = "Journals"
    let PosterUID = "PosterUID"
    let PatientName = "PatientName"
    let Post = "Post"
    let ImageURL = "PostImageURL"
    let Timestamp = "Timestamp"
    let Comments = "Comments"
    let comment = Comment()
}

struct Comment {
    let Comment = "Comment"
    let PosterUID = "PosterUID"
    let PosterName = "PosterName"
    let Timestamp = "Timestamp"
}

struct EncouragementBoard {
    let EncouragementBoards = "EncouragementBoards"
    let Message = "Message"
    let PosterUID = "PosterUID"
    let PatientName = "PatientName"
    let Timestamp = "Timestamp"
}

struct InviteCodes {
    let InviteCodes = "InviteCodes"
    let Patient = "Patient"
}

struct ProfilePictures {
    let ProfilePictures = "ProfilePictures"
}

struct Patient {
    let Patients = "Patients"
    let FirstName = "FirstName"
    let LastName = "LastName"
    let FullName = "FullName"
    let InviteCode = "InviteCode"
}

struct Reader {
    let Readers = "Readers"
    let FirstName = "FirstName"
    let LastName = "LastName"
    let FullName = "FullName"
    let ReadingFrom = "ReadingFrom"
    let PatientList = "PatientList"
}

struct Family {
    let Family = "Family"
    let FirstName = "FirstName"
    let LastName = "LastName"
    let FullName = "FullName"
    let PatientUID = "PatientUID"
}

struct PhotoAlbumStr {
    let PhotoAlbum = "PhotoAlbums"
    let Timestamp = "Timestamp"
    let URL = "URL"
}
