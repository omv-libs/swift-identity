# StronglyTypedID
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)

"Put an ID on it" and "use more functional programming" are the go-to solutions to any programming question these days.
This package won't help you with the latter, but it should make your experience of the former in a Swift environment a
lot more pleasant and safe.

This package allows Swift developers to make every ID type a distinct Swift type with extremely low effort, while not
getting in the way of codability and testability nor adding nearly any friction to any further development. Javascript
folks may just throw a string wherever but it's not like their programming language lets them easily do more than that.

## Support

This should work fine everywhere that Swift 5.7 can be used. It's currently configured to work on any platform supported
by Xcode 14 but I would happily accept a (tested) PR that adds support to Apple system versions before that and/or other
platforms.

## Adoption

Just declare a type that adopts the `StronglyTypedID` protocol, then add its `rawValue` —the Swift type system makes
us do that if we want the ID types to be distinct, which is much of the point of this exercise—.
 
For example if we want to manage our clowns with value model types, as is the current fashion, and identify them using
`UUID` values, we'd declare the following:
 
```swift
struct Clown: Identifiable {
    struct ID: StronglyTypedID {
        var rawValue: UUID
    }
    
    var id: ID
    
    var name: String
    
    var noseColor: CGColor
    
    var shoeSize: Double
    
    var musicalInstrument: MusicalInstrument
    
    /* ... */
} 
```

Nothing stops us from declaring similarly for reference types, although for `protocol` types we'd need to declare them
outside since Swift protocols don't allow for internal types. So if we ended up with an abstract façade for our clowns
we'd end up with the following:

```swift
struct ClownID: StronglyTypedID {
    var rawValue: UUID
}

protocol Clown: Identifiable {
    var id: ClownID { get }
    
    var name: String { get set }
    
    var noseColor: CGColor { get set }
    
    /* ... */
    
    func honk(times: Int)
    
    /* ... */
}
``` 

## Codability

`StronglyTypedID` includes a default implementation of `Codable` that avoids key-value coding for the contents. This is
awfully convenient when dealing with outside data like your typical JSON backend reply, which generally just has a
string field for the id of whatever data you're getting.

Continuing with our clownish conceit, we're moving into the clowns-as-a-service space and our backend is sending us back
the following available clowns:

```json
[
  {
    "id": "CD6AB6A4-3FE8-4B47-913B-B5F5D65DD6B2",
    "name": "Pagliacci",
    "noseColor": "0xff0000",
    "shoeSize": 18
  },
  {
    "id": "1DAFCD43-C8C8-40D9-B519-749B15B3A94F",
    "name": "Bozo",
    "noseColor": "0xffff00",
    "shoeSize": 10
  }
]
```

What do you need to do to decode those plain strings into our UUID IDs here? _absolutely nothing_. Well you might need
to be sure that the backend folks are always sending you v4 UUIDs in there since that's what the Foundation `UUID` type
supports. You'll probably also need to do something about those hex colors but that's just because this is a terrible
example.

Then again, what would you need to do to _encode_ your UUID-based strongly typed IDs into something that the backend can
chew on? _absolutely nothing_. They'll just encode themselves into the string form of the UUID and off you go.

## Testability

When writing tests, you are unlikely to care that your unique IDs are that unique to begin with. You have control over
them and may want to make sure they are easy to track through a test's execution and validation.

This applies mostly to types where there's no intrinsic validation to the ID raw value itself (in other words UUIDs
and other forms of global unique ID with specified formatting still need to be handled with care).

For those types of IDs, allowing for using string constants to build IDs makes setting up test data much simpler. Let's
assume that our `Clown` is using a `String`-based strongly typed ID and we are writing some unit tests for our
`ClownCar`

```swift
final class ClownCarTests: XCTestCase {
    func testSeventeenClowns() throws {
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
        XCTAssertNoThrow(try clownCar.jumpOverPiranhaPool())
        
        // Test that the clowns have been shaken but not stirred:
        for index in 1 ... seventeen {
            XCTAssertEqual(clownCar.clowns[index].id, "Clown-id-\(index)")
        }
    }
}
```

Well if you try to build that, it won't. However, if you add the following line, it will all build fine and you'll be
able to automate computerized cruelty to clowns:

```swift
extension Clown.ID: ExpressibleByStringInterpolation {}
```

The main reason we don't include this into `String`-based IDs by default is that we don't know which ones would support
it (just because a strongly typed ID is `String`-based doesn't mean it'll support any random `String` as a raw value)
and because generally you wouldn't want initialization by string constant to happen by accident in the real
application's code —you can still use `init(rawValue:)` them into being if needed—.
