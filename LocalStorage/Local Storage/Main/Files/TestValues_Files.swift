//
//  TestValues_Files.swift
//  localstorage
//
//  Created by Günther Eberl on 06.04.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import Foundation

public struct TestValues_Files {
    public static let description: String = "Files"
    
    public static let AllValues: [Double] = [
        1200000,
        23000000,
        54000000,
        120000000,
        24000000,
        100000000
    ]
    
    public struct FileInfo {
        public let name: String
        public let type: String
    }


    public static let FileInfos: [FileInfo] = [
        FileInfo(name: "my_favorite_song.mp3", type: LocalizedTypeNames.audio),
        FileInfo(name: "Auld Lang Syne.flac", type: LocalizedTypeNames.audio),
        FileInfo(name: "Movie Trailer 2018.mkv",  type: LocalizedTypeNames.videos),
        FileInfo(name: "manual.pdf",   type: LocalizedTypeNames.documents),
        FileInfo(name: "DCIM234235.JPG",  type: LocalizedTypeNames.images),
        FileInfo(name: "some_unrecognoized.file",  type: LocalizedTypeNames.other)
    ]
}
