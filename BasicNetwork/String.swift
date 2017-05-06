//
//  String.swift
//  BasicNetwork
//
//  Created by Theis Egeberg on 04/05/2017.
//  Copyright © 2017 Theis Egeberg. All rights reserved.
//

import Foundation

extension String {
    public func jsonIndented() -> String {
        let characters = self.characters

        var indentCount: Int = 0
        var finalString = ""

        characters.forEach { (character) in

            if character == "}" || character == "]" {
                indentCount = indentCount - 1
                finalString.append("\n")
                finalString.append(String(repeating: " ", count: indentCount))
            }

            finalString.append(character)

            if character == "," {
                finalString.append("\n")
                finalString.append(String(repeating: " ", count: indentCount))
            }

            if character == "{" || character == "[" {
                indentCount = indentCount + 1
                finalString.append("\n")
                finalString.append(String(repeating: " ", count: indentCount))
            }

            switch character {
            case "{":
                indentCount = indentCount + 1
                break
            case "}":
                indentCount = indentCount - 1
                break
            default:
                break
            }
        }
        return finalString

    }
}
