/*:
 # Swift Lift: Enum it up
 ## Make impossible states impossible
 
 
 
 What is a Swift Lift?
 
 
 
 A short workshop illustrating why some aspect of Swift will make your work easier
 
 
 
 How do we make impossible states impossible?
 
 
 
 Domain modelling with types
 
 
 
 What is domain modelling?
 
 
 
 The act of expressing your real world task or idea into software. We do this all the time (even if we don't realize it).
 
 
 
Let's get started
 */

/*:
 Real Life Problem:
 
 > I'm computing the location of an image on some server. I either have a url string to an image or I have an S3 key and bucket. I always have one or the other and never both.
 
 
```
   // equivalent to this representation in ObjC
   @interface PIImageLocator
   @property (nonatomic, strong) nullable NSString *url
   @property (nonatomic, strong) nullable NSString *s3key
   @property (nonatomic, strong) nullable NSString *s3bucket
   @end
```
 
 */
// A "Bad" representation in Swift
struct PIImageLocator1 {
    let url: String?
    let s3key: String?
    let s3bucket: String?
    
    // computed property
    var realUrl: String {
        if let url = url {
            return url
        } else {
            return "http://pinterest.s3." +
                s3bucket! +
                "." +
                s3key!
        }
    }
}

/*:
  Why is the above code a bad model of this problem:
 
 > I'm computing the location of an image on some server. I either have a url string to an image or I have an S3 key and bucket. I always have one or the other and never both.
*/

/*:
 Excersize: Why
 
 The following invalid states ARE representable:
 1. A key but not a bucket or vice versa
 2. Neither the key/bucket nor the url, when the whole thing itself isn't nil (nil,nil,nil)
 3. Both a key/bucket and a url
 ...
 */

// slightly better
struct PIImageLocator2 {
    struct S3Info {
        let bucket: String
        let key: String
    }
    let url: String?
    let s3: S3Info?
    
    var realUrl: String {
        if let url = url {
            return url
        } else {
            let info = s3!
            return "http://pinterest.s3." +
                info.bucket +
                "." +
                info.key
        }
    }
}

//: This is better because we are forced now to pass *both* a key and a bucket if we're passing some s3 information. But it still doesn't stop us from passing nil to both or worse, values to both by accident.


/*: Aside:
 
 In Objective-C, enums are basically just integers:
 
 ```
 typedef NS_ENUM(NSInteger, PIColor) {
     PIColorGreen,
     PIColorRed,
     PIColorBlue,
 };
 ```
 
 In Swift, enums can have *data* associated with them:
 */

 enum Barcode {
     case qr(code: String)
     case upc(Int, Int, Int, Int)
 }

//: Back to our problem:

// The invariant is that it's one or the other, so we can whip out an enum for that.
enum PIImageLocator3 {
    case url(String)
    case s3(bucket: String, key: String)
    
    var realUrl: String {
        switch self {
        case let .url(u): return u
        case let .s3(bucket: bucket, key: key):
            return "http://pinterest.s3." +
                bucket +
                "." +
                key
        }
    }
}

/*:
 Look carefully at the difference between the 3 implementations, what is different?
 
 We don't need to force-unwrap anywhere and we don't need excessive conditionals. This is a sign you did it right.

 Proper domain modelling is translating problem statement to types.
 
 Productivity wins:
 
 
 1. Faster dev feedback loop:
 
 
 You don't need to wait for something to build to find simple mistakes
 
 
 2. Faster debug feedback loop:
 
 
 An entire class of "stupid mistakes" no longer happens
 
 
 3. Easier to maintain (readable):
 
 
 You don't have to read the body of functions or comments to understand constraints. Only types and signatures.
 Code is FAR more precise than English as long as we all get comfortable with the language.
 
 
 4. Easier to maintain (writable):
 
 
 You don't need to update documentation or assertions or even UNIT TESTS (which as an ios group we'll get better at soon) for the cases you capture in types. There is NO risk of code becoming out of sync with documentation.
 
 */

/*:
 Thinking about *relying* on types helps describe behavior:
 
 If I see `String?, String?, String?` that means I'm free to pass nil to any combination of them.
 You shouldn't crash and even worse, you shouldn't do something that's strange.
 What does `PIImageLocator1(url: nil, s3key: nil, s3bucket: nil)` even mean?
 */

//: Excersize

struct User {
    let name: String
    // ...
}
enum UserState {
    case loggedOut
    case loggedIn(User)
    
    //: Excersize: Return the name of the user or "Logged out" if no user is logged in.
    var displayName: String {
        // Hint, look above for an example on how to switch
        return ""
    }
}

//: Enum


//: Excersize: We want a data structure that captures the idea of getting a String from the network with a success status code (like 200 "Success") or a failure from our backend (like 503 "Unauthorized") or a failure because airplane mode is on (with no associated data)

enum NetworkResult {
    // case ...
    
    //: Excersize: Now implement a method that outputs the successful value or the failure to a string
    var debugString: String {
        return ""
    }
}







//: Bonus

enum MyOptional<Element> {
    case some(Element)
    case none
}

// In Swift's standard Optional, this type has some syntactic suger
// let x: Optional<Int> = 4 // same as .some(4)
// let y: Optional<Int> = nil // same as .none

//: This is just the option in Swift looks like

//: Note: .first exists on sequences in Swift
func head(arr: [Int]) -> Optional<Int> {
    if arr.count == 0 {
        return .none
    } else {
        return .some(arr[0])
    }
}

// Protip: You can do this today with the PI_ONE_OF macro, but it's native in swift.

/*:
Excersize
 
```
 (.none).getOrElse(4) => 4
 (.some("a")).getOrElse("") => "a"
```
 */
 
// Protip: This is equivalent to Swift Optional's `??` operator
extension MyOptional {
    func getOrElse(orElse fallback: Element) -> Element {
        // ...
    }
}

//: Even linked-lists can be modelled as enums

indirect enum List<T> {
    case empty
    case cons(T, List<T>)
}


