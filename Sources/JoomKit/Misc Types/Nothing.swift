//
//  Nothing.swift
//  Joom
//
//  Created by Artem Starosvetskiy on 15.03.2020.
//  Copyright © 2020 Joom. All rights reserved.
//

struct Nothing {
    public init() {}
}

extension Nothing: Equatable {
    public static func == (lhs: Nothing, rhs: Nothing) -> Bool {
        true
    }
}

extension Nothing: Hashable {
    public func hash(into hasher: inout Hasher) {
        // Do nothing
    }
}

extension Nothing: Codable {
    public init(from decoder: Decoder) throws {
        // Do nothing
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        // `JSONEncoder` requires any value to be encoded.
        try container.encodeNil()
    }
}
