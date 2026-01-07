// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import StandardsTestSupport
import Testing

@testable import Kernel_Primitives

extension Kernel.File.Permissions {
    #TestSuites
}

// MARK: - Unit Tests

extension Kernel.File.Permissions.Test.Unit {
    @Test("Permissions from rawValue")
    func rawValueInit() {
        let perms = Kernel.File.Permissions(rawValue: 0o644)
        #expect(perms.rawValue == 0o644)
    }

    @Test("Permissions from integer literal")
    func integerLiteralInit() {
        let perms: Kernel.File.Permissions = 0o755
        #expect(perms.rawValue == 0o755)
    }
}

// MARK: - Owner Permissions

extension Kernel.File.Permissions.Test.Unit {
    @Test("ownerRead constant")
    func ownerRead() {
        #expect(Kernel.File.Permissions.ownerRead.rawValue == 0o400)
    }

    @Test("ownerWrite constant")
    func ownerWrite() {
        #expect(Kernel.File.Permissions.ownerWrite.rawValue == 0o200)
    }

    @Test("ownerExecute constant")
    func ownerExecute() {
        #expect(Kernel.File.Permissions.ownerExecute.rawValue == 0o100)
    }

    @Test("ownerReadWrite constant")
    func ownerReadWrite() {
        #expect(Kernel.File.Permissions.ownerReadWrite.rawValue == 0o600)
    }

    @Test("ownerAll constant")
    func ownerAll() {
        #expect(Kernel.File.Permissions.ownerAll.rawValue == 0o700)
    }
}

// MARK: - Group Permissions

extension Kernel.File.Permissions.Test.Unit {
    @Test("groupRead constant")
    func groupRead() {
        #expect(Kernel.File.Permissions.groupRead.rawValue == 0o040)
    }

    @Test("groupWrite constant")
    func groupWrite() {
        #expect(Kernel.File.Permissions.groupWrite.rawValue == 0o020)
    }

    @Test("groupExecute constant")
    func groupExecute() {
        #expect(Kernel.File.Permissions.groupExecute.rawValue == 0o010)
    }

    @Test("groupReadWrite constant")
    func groupReadWrite() {
        #expect(Kernel.File.Permissions.groupReadWrite.rawValue == 0o060)
    }

    @Test("groupAll constant")
    func groupAll() {
        #expect(Kernel.File.Permissions.groupAll.rawValue == 0o070)
    }
}

// MARK: - Other Permissions

extension Kernel.File.Permissions.Test.Unit {
    @Test("otherRead constant")
    func otherRead() {
        #expect(Kernel.File.Permissions.otherRead.rawValue == 0o004)
    }

    @Test("otherWrite constant")
    func otherWrite() {
        #expect(Kernel.File.Permissions.otherWrite.rawValue == 0o002)
    }

    @Test("otherExecute constant")
    func otherExecute() {
        #expect(Kernel.File.Permissions.otherExecute.rawValue == 0o001)
    }

    @Test("otherReadWrite constant")
    func otherReadWrite() {
        #expect(Kernel.File.Permissions.otherReadWrite.rawValue == 0o006)
    }

    @Test("otherAll constant")
    func otherAll() {
        #expect(Kernel.File.Permissions.otherAll.rawValue == 0o007)
    }
}

// MARK: - Presets

extension Kernel.File.Permissions.Test.Unit {
    @Test("none constant")
    func noneConstant() {
        #expect(Kernel.File.Permissions.none.rawValue == 0o000)
    }

    @Test("standard constant (rw-r--r--)")
    func standardConstant() {
        #expect(Kernel.File.Permissions.standard.rawValue == 0o644)
    }

    @Test("executable constant (rwxr-xr-x)")
    func executableConstant() {
        #expect(Kernel.File.Permissions.executable.rawValue == 0o755)
    }

    @Test("privateFile constant (rw-------)")
    func privateFileConstant() {
        #expect(Kernel.File.Permissions.privateFile.rawValue == 0o600)
    }

    @Test("privateExecutable constant (rwx------)")
    func privateExecutableConstant() {
        #expect(Kernel.File.Permissions.privateExecutable.rawValue == 0o700)
    }

    @Test("privateDirectory constant (rwx------)")
    func privateDirectoryConstant() {
        #expect(Kernel.File.Permissions.privateDirectory.rawValue == 0o700)
    }

    @Test("standardDirectory constant (rwxr-xr-x)")
    func standardDirectoryConstant() {
        #expect(Kernel.File.Permissions.standardDirectory.rawValue == 0o755)
    }
}

// MARK: - Operators

extension Kernel.File.Permissions.Test.Unit {
    @Test("OR operator combines permissions")
    func orOperator() {
        let combined = Kernel.File.Permissions.ownerRead | .ownerWrite
        #expect(combined.rawValue == 0o600)
    }

    @Test("OR assignment operator")
    func orAssignmentOperator() {
        var perms = Kernel.File.Permissions.ownerRead
        perms |= .ownerWrite
        #expect(perms.rawValue == 0o600)
    }

    @Test("AND operator intersects permissions")
    func andOperator() {
        let result = Kernel.File.Permissions.standard & .ownerReadWrite
        #expect(result.rawValue == 0o600)
    }

    @Test("NOT operator inverts permissions")
    func notOperator() {
        let inverted = ~Kernel.File.Permissions.none
        #expect(inverted.rawValue == 0xFFFF)
    }
}

// MARK: - Description

extension Kernel.File.Permissions.Test.Unit {
    @Test("description for standard (rw-r--r--)")
    func standardDescription() {
        #expect(Kernel.File.Permissions.standard.description == "rw-r--r--")
    }

    @Test("description for executable (rwxr-xr-x)")
    func executableDescription() {
        #expect(Kernel.File.Permissions.executable.description == "rwxr-xr-x")
    }

    @Test("description for none (---------)")
    func noneDescription() {
        #expect(Kernel.File.Permissions.none.description == "---------")
    }

    @Test("description for all (rwxrwxrwx)")
    func allDescription() {
        let all: Kernel.File.Permissions = 0o777
        #expect(all.description == "rwxrwxrwx")
    }
}

// MARK: - Conformances

extension Kernel.File.Permissions.Test.Unit {
    @Test("Permissions is Sendable")
    func isSendable() {
        let perms: any Sendable = Kernel.File.Permissions.standard
        #expect(perms is Kernel.File.Permissions)
    }

    @Test("Permissions is Equatable")
    func isEquatable() {
        let a = Kernel.File.Permissions.standard
        let b = Kernel.File.Permissions(rawValue: 0o644)
        let c = Kernel.File.Permissions.executable
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Permissions is Hashable")
    func isHashable() {
        var set = Set<Kernel.File.Permissions>()
        set.insert(.standard)
        set.insert(.executable)
        set.insert(.standard)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Permissions.Test.EdgeCase {
    @Test("combining all individual permissions equals 0o777")
    func combineAll() {
        let all =
            Kernel.File.Permissions.ownerRead
            | .ownerWrite
            | .ownerExecute
            | .groupRead
            | .groupWrite
            | .groupExecute
            | .otherRead
            | .otherWrite
            | .otherExecute
        #expect(all.rawValue == 0o777)
    }

    @Test("preset combinations are correct")
    func presetCombinations() {
        let expectedOwnerReadWrite = Kernel.File.Permissions.ownerRead | .ownerWrite
        #expect(Kernel.File.Permissions.ownerReadWrite == expectedOwnerReadWrite)

        let expectedGroupReadWrite = Kernel.File.Permissions.groupRead | .groupWrite
        #expect(Kernel.File.Permissions.groupReadWrite == expectedGroupReadWrite)

        let expectedOtherReadWrite = Kernel.File.Permissions.otherRead | .otherWrite
        #expect(Kernel.File.Permissions.otherReadWrite == expectedOtherReadWrite)
    }
}
