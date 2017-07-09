//
//  Default.swift
//  PitchPerfect
//
//  Created by Shobhit Gupta on 26/03/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import Foundation

public enum Default {
    // Extend Default in individual files.
    // Then import this file along with specific files that need to be reused in future projects.
}


// Add/Remove or Comment/Uncomment nested enums according to which piece of code you reuse.


public extension Default {
    public enum Audio {}
    public enum DispatchQueue_ {
        public enum Label {}
    }
    public enum FileManager_ {}
    public enum Map {}
    public enum UIImage_ {}
    public enum UIView_ {}
    public enum URL_ {}
}


public extension Default.DispatchQueue_.Label {
    static let Main = Bundle.main.bundleIdentifier ?? "com.from101"
}
