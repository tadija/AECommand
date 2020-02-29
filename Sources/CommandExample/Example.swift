import Foundation
import AEShell
import AECli
import AETool

public struct Example: Command {
    public var overview: String {
        "demo command for ae tool"
    }

    public var commands: [Command] {
        [Foo(), Bar(), Group(), Chain(), Config(), Memory(), Sh()]
    }

    public init() {}
}

struct Foo: Command {
    var overview: String {
        "output foo"
    }

    func run(_ arguments: [String] = [], in cli: Cli) throws {
        cli.output("foo something")
    }
}

struct Bar: Command {
    var overview: String {
        "output bar"
    }

    func run(_ arguments: [String] = [], in cli: Cli) throws {
        cli.output("bar something")
    }
}

struct Group: Command {
    var overview: String {
        "group foo and bar commands"
    }

    let commands: [Command] = [
        Foo(),
        Bar()
    ]
}

struct Chain: Command {
    var overview: String {
        "chain foo and bar commands"
    }

    func run(_ arguments: [String] = [], in cli: Cli) throws {
        try Foo().run(in: cli)
        try Bar().run(in: cli)
    }
}

struct Config: Command {
    var overview: String {
        "demo local config"
    }

    var commands: [Command] {
        [Default(), Custom()]
    }

    struct Default: Command {
        var overview: String {
            "output `foo` from default local config (ae.json)"
        }

        func run(_ arguments: [String] = [], in cli: Cli) throws {
            guard let value = local["foo"] as? String else {
                throw "Config value is missing for key 'foo'"
            }
            cli.output(value)
        }
    }

    struct Custom: Command {
        var overview: String {
            "output `foo` from custom local config (config/custom.json)"
        }

        func run(_ arguments: [String] = [], in cli: Cli) throws {
            let custom = FileConfig("config/custom.json")
            guard let value = custom["foo"] as? String else {
                throw "Config value is missing for key 'foo'"
            }
            cli.output(value)
        }
    }
}

struct Memory: Command {
    var overview: String {
        "demo tool memory"
    }

    func validate(_ arguments: [String]) throws {
        guard arguments.count == 2 else {
            throw "invalid arguments: 2 required (key and value)"
        }
    }

    func run(_ arguments: [String] = [], in cli: Cli) throws {
        try validate(arguments)
        let key = arguments[0]
        let value = arguments[1]
        try Write().run([key, value], in: cli)
        try Read().run([key], in: cli)
    }

    struct Write: Command {
        var overview: String {
            "write to memory"
        }

        func run(_ arguments: [String] = [], in cli: Cli) throws {
            let key = arguments[0]
            let value = arguments[1]
            memory[key] = value
            cli.output("memory save: \(value) for key \(key)")
        }
    }

    struct Read: Command {
        var overview: String {
            "read from memory"
        }

        func run(_ arguments: [String] = [], in cli: Cli) throws {
            let key = arguments[0]
            let value = memory[key] as? String ?? "n/a"
            cli.output("memory read: \(value) for key \(key)")
        }
    }
}

struct Sh: Command {
    var overview: String {
        "run shell command"
    }

    func validate(_ arguments: [String]) throws {
        guard !(arguments.first ?? "").isEmpty else {
            throw "invalid arguments: 1 required (shell command)"
        }
    }

    func run(_ arguments: [String] = [], in cli: Cli) throws {
        try validate(arguments)
        let result = try Shell().run(arguments.joined(separator: " "))
        if !result.isEmpty {
            cli.output(result, color: .yellow)
        }
    }
}
