# swift-identity
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)

"Put an ID on it" and "use more functional programming" are the go-to solutions to any programming question these days.
This package won't help you with the latter, but it should make your experience of the former in a Swift environment a
lot more pleasant and safe.

This package allows Swift developers to make every ID type a distinct Swift type with extremely low effort, while not
getting in the way of codability and testability nor adding nearly any friction to any further development. Javascript
folks may just throw a string wherever but it's not like their programming language lets them easily do more than that.

## Support

This package vends a number of macros and is asking for Swift 6.1 but can otherwise work on any platform supported by
Xcode 16. Earlier versions of the package can be used with earlier tooling and their earlier supported OS versions,
since macro support is the only dependency forcing the newer toolset and minimum OS version deployment.

## Adoption

The easiest way to adopt is to just use one of the `Identifier` macros. You only need to parameterize it with its
backing type.

For global scope identifiers you'll need to declare the type by hand since macros are not allowed to do so. You can
however use the attached `@Identifier` macro to take care of the busywork. For example if we want to keep track of our
clowns with a dedicated `UUID` backed ID we would just need to write the following:

```swift
@Identifier<UUID> struct ClownID {}
```

Of course we could also add anything else to that type declaration as needed, say for example if we want to add some
functionality to the ID itself:

```swift
@Identifier<UUID> struct ClownID: Honkable, Slappable {
    func honk() {
        AudioOutput.shared.play(sound: .honk, volume: 11)
    }
    
    // ...
}
```

If we have, say, a `Clown` model type and we'd rather embed the identifier type within, we can use the `#Identifier`
macro instead as follows:

```swift
struct Clown: Identifiable {
    #Identifier<UUID>("ID")
    
    var id: ID
    
    var name: String
    
    var noseColor: CGColor
    
    var shoeSize: Double
    
    var musicalInstrument: MusicalInstrument
    
    /* ... */
} 
```

After which we would refer to the type from elsewhere as `Clown.ID`
 
Beyond that the macros are usable anywhere where the expanded code would make sense and be allowed by the compiler. For
example you cannot declare a type within a protocol, which means a theoretical `protocol Clown: Identifiable` would need
its `ID` type declared outside its protocol declaration scope.

```swift
@Identifier<UUID> struct ClownID {}

protocol Clown: Identifiable {
    var id: ClownID { get }
    
    var name: String { get set }
    
    var noseColor: CGColor { get set }
    
    /* ... */
    
    func honk(times: Int)
    
    /* ... */
}
```

The attached macro also allows for more sophisticated use cases i.e. ID type hierarchies. For example, say that we have
become victims of feature creep and started building a comprehensive circus HR solution. We may end up wanting to make
sure that our clowns are, despite everything they've done, treated the same as any other human being working for the
circus. As such you could add common parent protocols to the ID types as to be able to use
them in common functionality:

```swift
protocol Performer {
    var hourlyWage: Decimal { get }

    // ...
}

protocol PerformerID: Identifier {}

struct Clown: Identifiable, Performer {
    @Identifier<UUID> struct ID: PerformerID {}

    var id: ID

    let hourlyWage = Decimal(7.25)

    // ...
}

struct Acrobat: Identifiable {
    @Identifier<UUID> struct ID: PerformerID {}

    var id: ID

    let hourlyWage = Decimal(50.00)

    // ...
}

protocol Payroll {
    func pay(performer: some PerformerID, period: TimeInterval) -> Decimal

    // ...
}
```

## Codability

`Identifier` includes a default implementation of `Codable` that avoids key-value coding for the contents. This is
awfully convenient when dealing with outside data like your typical JSON backend reply, which generally just has a
string field for the id of whatever data you're getting.

Continuing with our clownish conceit, we're moving into the clowns-as-a-service space and our backend is sending us back
the following available clowns:

```json
[
  {
    "id": "cd6ab6a4-3fe8-4b47-913b-b5f5d65dd6b2",
    "name": "Pagliacci",
    "noseColor": "0xff0000",
    "shoeSize": 18
  },
  {
    "id": "1dafcd43-c8c8-40d9-b519-749b15b3a94f",
    "name": "Bozo",
    "noseColor": "0xffff00",
    "shoeSize": 10
  }
]
```

What do you need to do to decode those plain strings into our UUID IDs here? _absolutely nothing_. Well you might need
to be sure that the backend folks are always sending you v4 UUIDs in there since that's what the Foundation `UUID` type
supports. You'll probably also need to do something about those hex colors but that's just because this is a terribly
contrived example.

Then again, what would you need to do to _encode_ your UUID-based strongly typed IDs into something that the backend can
chew on? _absolutely nothing_. Usually, that is. As a gesture of friendship to long-suffering backend developers a
`UUID`-backed strongly typed ID will encode in lowercase, since that's almost always what the backend expects. Other
than that they'll just encode themselves into the string form of the UUID and off you go. If additional work is required
to translate into peculiar backend expectations, you can always add a custom `Encodable` implementation to your
identifier type.

## Testability

When writing tests, you are unlikely to care that your unique IDs are that unique to begin with. You have control over
them and may want to make sure they are easy to track through a test's execution and validation.

This applies mostly to types where there's no intrinsic validation to the ID raw value itself (in other words UUIDs
and other forms of global unique ID with specified formatting may still need to be handled with care).

For those types of IDs, allowing for using string constants to build IDs makes setting up test data much simpler. Let's
assume that our `Clown` is using a `String`-backed `Identifer` type and we are writing some unit tests for our
`ClownCar`

```swift
struct ClownCarTests {
    @Test("Light loading test") func seventeenClowns() throws {
        let seventeen = 17
        let clownCar = ClownCar()
        for index in 1 ... seventeen {
            clownCar.insert(Clown(
                id: "Clown-id-\(index)",
                name: "Clown #\(index)",
                /* ... */
            ))
        }

        // Test that the clowns survive.
        #expect(throws: Never.self) {
            try clownCar.jumpOverPiranhaPool()
        }
        
        // Test that the clowns have been shaken but not stirred:
        for index in 1 ... seventeen {
            #expect(clownCar.clowns[index].id == "Clown-id-\(index)")
        }
    }
}
```

Well if you try to build that, it won't. However, if you add the following line, it will all build fine and you'll be
able to automate computerized cruelty to clowns:

```swift
extension Clown.ID: ExpressibleByStringInterpolation {}
```

`Identifier` does not automatically conform to these protocols to allow the developer to choose whether static constants
of the backing type will be allowed to be assigned into them or an explicit call will be needed. Particularly important
when not every value of the backing type makes for a valid identifier type value.

## Known Issues

* Cannot use `#Identifier` on global scope since Swift does not allow macros to declare new types on global scope.
* Generating new `Identifier` types using either macro within a function body will not work for similar reasons. This is
not an expected use case except possibly in unit tests, and there's easy enough workaround in that case (declare the
types outside the test function).
