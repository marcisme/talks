# Flexible Array Members
## in<br>Swift

^ using C APIs from Swift?

^ familiar with C?

^ it's been a long time since college...

^ the problem, how to in C, how to in Swift, recommendations

---

# AudioBufferList

``` c
struct AudioBufferList {
    UInt32 mNumberBuffers;
    AudioBuffer mBuffers[1];
};
```

``` swift
struct AudioBufferList {
    var mNumberBuffers: UInt32
    var mBuffers: (AudioBuffer)
}
```
---

# In an Ideal World

``` swift
let audioBuffers = [
    AudioBuffer(...),
    AudioBuffer(...)
]

var audioBufferList = AudioBufferList()
audioBufferList.mNumberBuffers = UInt32(audioBuffers.count)
audioBufferList.mBuffers = audioBuffers // problems start here
```

^ all code is based on Swift 1.2

---

# Here in Reality

``` swift
audioBufferList.mBuffers = audioBuffers
```

results in:

> Cannot assign a value of type '[AudioBuffer]'<br> to a value of type '(AudioBuffer)'
-- Swift Compiler

---

# A Tuple is not an Array

``` c
struct AudioBufferList {
    UInt32 mNumberBuffers;
    AudioBuffer mBuffers[1]; // C array
};
```

``` swift
struct AudioBufferList {
    var mNumberBuffers: UInt32
    var mBuffers: (AudioBuffer) // (AudioBuffer) == AudioBuffer
}
```

---

# Flexible Array Member

* "struct hack"[^1] became formalized in C99[^2]
* fixed length struct members must include a count
* the variable length struct member must be last
* create with `malloc` and pass by pointer
* be aware of memory alignment issues

[^1]: http://c-faq.com/struct/structhack.html

[^2]: http://www.open-std.org/jtc1/sc22/WG14/www/docs/n1256.pdf

^ portability

---

# One Buffer to Rule Them All

``` c
struct AudioBufferList {
    UInt32 mNumberBuffers;
    AudioBuffer mBuffers[1];
};
```

memory layout:

``` bash
|---fixed---|
|           |
|--4 bytes--|--16 bytes--|
            |            |
            |--variable--|
```

---

# Two Buffers

``` c
struct AudioBufferList {
    UInt32 mNumberBuffers;
    AudioBuffer mBuffers[1];
};
```

same type, more memory ???

``` bash
|---fixed---|
|           |
|--4 bytes--|--16 bytes--|--16 bytes--|
            |                         |
            |--------variable---------|
```

---

# Objective-C Allocation

``` c
size_t fixedLengthMemberSize = offsetof(AudioBufferList, mBuffers[0]);
size_t variableLengthMemberSize = sizeof(AudioBuffer) * 2;
size_t totalSize = fixedLengthMemberSize + variableLengthMemberSize;

AudioBufferList *audioBufferList = malloc(size);
```

``` bash
          |-offsetof(AudioBufferList, mBuffers[0])
          v
|--fixed--|--------variable---------|
          |                         |
          |-sizeof(AudioBuffer) * 2-|

```

---

# Objective-C Usage

``` c
audioBufferList->mNumberBuffers = 2;

audioBufferList->mBuffers[0].mNumberChannels = 1;
...
audioBufferList->mBuffers[1].mNumberChannels = 1;
...

// don't forget to free the memory at some point
free(audioBufferList);
```

^ address sanitizer?

---

# UnsafeMutablePointer<Memory>[^3]

"A pointer to an object of type Memory. This type provides no automated memory management, and therefore the user must take care to allocate and free memory appropriately."

``` bash
 |-------------UMP<UInt8>--------------|
 |                                     |
 |--4 bytes--|--16 bytes--|--16 bytes--|
 |                        |
 |--UMP<AudioBufferList>--|
```

[^3]: http://swiftdoc.org/type/UnsafeMutablePointer/

---

# Swift Allocation[^4]

In Swift, use `strideof` where you would use `sizeof` in ObjC[^5]

``` swift
var audioBuffers = [...]

let size = strideof(AudioBufferList) + strideof(AudioBuffer) * (audioBuffers.count - 1)
let memoryPointer = UnsafeMutablePointer<UInt8>.alloc(size)
```

[^4]: http://stackoverflow.com/questions/27724055/initializing-midimetaevent-structure

[^5]: https://devforums.apple.com/message/1086617#1086617

---

# Swift Usage

In Swift we dereference with the `memory` property.

``` swift
var audioBufferListPointer = UnsafeMutablePointer<AudioBufferList>(memoryPointer)

audioBufferListPointer.memory.mNumberBuffers = UInt32(audioBuffers.count)

// this doesn't work here either
audioBufferListPointer.memory.mBuffers = ...
```

^ SO to the rescue!

---

# Swift Usage

Memory layout is only guaranteed for structs declared in C.

``` swift
var audioBufferListPointer: UnsafeMutablePointer<AudioBufferList>(memoryPointer) = ...

memcpy(&audioBufferListPointer.memory.mBuffers, &audioBuffers, size)

// don't forget to release the memory when you're done
memoryPointer.dealloc(size)
```

^ can't read or directly access values

---

# Swift Wrapper

``` swift
class AudioBufferListWrapper {

    let count: Int

    var audioBufferListPointer: UnsafeMutablePointer<AudioBufferList>

    private let size: Int
    private let memoryPointer: UnsafeMutablePointer<UInt8>

    init(count: Int) {
        self.count = count
        self.size = strideof(AudioBufferList) + strideof(AudioBuffer) * (count - 1)

        self.memoryPointer = UnsafeMutablePointer<UInt8>.alloc(size)
        audioBufferListPointer = UnsafeMutablePointer<AudioBufferList>(memoryPointer)

        audioBufferListPointer.memory.mNumberBuffers = UInt32(count)

        // we still need to populate the AudioBufferList
    }

    deinit {
        memoryPointer.dealloc(size)
    }

}
```

^ reusable

^ handles memory management for you

---

# UnsafeMutableBufferPointer<Element>[^6]

"A non-owning pointer to buffer of mutable Elements stored contiguously in memory, presenting a Collection interface to the underlying elements."

``` bash
 |-------------UMP<UInt8>--------------|
 |                                     |
 |--4 bytes--|--16 bytes--|--16 bytes--|
             |                         |
             |----UMBP<AudioBuffer>----|
```

[^6]: http://swiftdoc.org/type/UnsafeMutableBufferPointer/

---

# Swift Wrapper Redux

``` swift
class AudioBufferListWrapper {

    let count: Int

    var audioBufferListPointer: UnsafeMutablePointer<AudioBufferList>

    private let size: Int
    private let memoryPointer: UnsafeMutablePointer<UInt8>
    private let audioBuffersPointer: UnsafeMutableBufferPointer<AudioBuffer> // our buffer pointer

    init(count: Int) {
        self.count = count
        self.size = strideof(AudioBufferList) + strideof(AudioBuffer) * (count - 1)

        self.memoryPointer = UnsafeMutablePointer<UInt8>.alloc(size)
        audioBufferListPointer = UnsafeMutablePointer<AudioBufferList>(memoryPointer)

        audioBufferListPointer.memory.mNumberBuffers = UInt32(count)

        // initialize our buffer pointer
        audioBuffersPointer = UnsafeMutableBufferPointer(start: &audioBufferListPointer.memory.mBuffers, count: count)
    }

    deinit {
        memoryPointer.dealloc(size)
    }

}
```

^ `UMP<AudioBufferList>` used for fixed access gives us variable offset

---

# Adopt MutableCollectionType

``` swift
extension AudioBufferListWrapper: MutableCollectionType {

    var startIndex: Int { return 0 }
    var endIndex: Int { return count }

    func generate() -> IndexingGenerator<AudioBufferListWrapper> {
        return IndexingGenerator(self)
    }

    subscript (index: Int) -> AudioBuffer {
        get {
            return audioBuffersPointer[index]
        }
        set {
            audioBuffersPointer[index] = newValue
        }
    }

}
```

^ we can use IndexingGenerator

^ delegate to `UMBP<AudioBuffer>`

---

# Swift Wrapper Usage

``` swift
let wrapper = AudioBufferListWrapper(count: 2)
wrapper[0] = AudioBuffer(...)
wrapper[1] = AudioBuffer(...)

let firstBuffer = wrapper[0]
let secondBuffer = wrapper[1]

SomeCFunction(wrapper.audioBufferListPointer)
```

---

# Apple's Take

``` swift
extension AudioBufferList {
    static func sizeInBytes(#maximumBuffers: Int) -> Int
    static func allocate(#maximumBuffers: Int) -> UnsafeMutableAudioBufferListPointer
}

extension AudioBuffer {
    init<T>(_ typedBuffer: UnsafeMutableBufferPointer<T>, numberOfChannels: Int)
}

struct UnsafeMutableAudioBufferListPointer {
    init(_ p: UnsafeMutablePointer<AudioBufferList>)
    var count: Int { get nonmutating set }
    var unsafePointer: UnsafePointer<AudioBufferList> { get }
    var unsafeMutablePointer: UnsafeMutablePointer<AudioBufferList>
}

extension UnsafeMutableAudioBufferListPointer : MutableCollectionType {
    func generate() -> IndexingGenerator<UnsafeMutableAudioBufferListPointer>
    var startIndex: Int { get }
    var endIndex: Int { get }
    subscript (index: Int) -> AudioBuffer { get nonmutating set }
}

```

^ discuss struct vs object ???

^ commented version online in repo

---

# Recommendations

* avoid `memcpy` approach
  * write only
  * depends on C struct memory layout
* use ObjC or Apple wrappers for light usage
* consider custom wrappers
  * for heavy usage
  * teams with less C experience

---

# Frameworks with FAM Structs

* AudioToolbox
* AudioUnit
* CoreAudio
* CoreMIDI
* CoreText
* CoreVideo
* GLKit
* vImage

---

# Marc Schwieterman
## [@mschwieterman](https://twitter.com/mschwieterman)
## [marcschwieterman.com](http://marcschwieterman.com)
## [initiative.fm](http://initiative.fm)
## [github.com/marcisme/talks/tree/master/FAM](https://github.com/marcisme/talks/tree/master/FAM)

