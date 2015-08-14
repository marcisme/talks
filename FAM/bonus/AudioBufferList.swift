import CoreAudio.AudioHardware
import CoreAudio.CoreAudioTypes
import CoreAudio.HostTime
import CoreAudio

extension AudioBufferList {

    /// :returns: the size in bytes of an `AudioBufferList` that can hold up to
    /// `maximumBuffers` `AudioBuffer`\ s.
    static func sizeInBytes(#maximumBuffers: Int) -> Int

    /// Allocate an `AudioBufferList` with a capacity for the specified number of
    /// `AudioBuffer`\ s.
    ///
    /// The `count` property of the new `AudioBufferList` is initialized to
    /// `maximumBuffers`.
    ///
    /// The memory should be freed with `free()`.
    static func allocate(#maximumBuffers: Int) -> UnsafeMutableAudioBufferListPointer
}

extension AudioBuffer {

    /// Initialize an `AudioBuffer` from an `UnsafeMutableBufferPointer<T>`.
    init<T>(_ typedBuffer: UnsafeMutableBufferPointer<T>, numberOfChannels: Int)
}


/// A wrapper for a pointer to an `AudioBufferList`.
///
/// Like `UnsafeMutablePointer`, this type provides no automated memory
/// management and the user must therefore take care to allocate and free
/// memory appropriately.
struct UnsafeMutableAudioBufferListPointer {

    /// Construct from an `AudioBufferList` pointer.
    init(_ p: UnsafeMutablePointer<AudioBufferList>)

    /// The number of `AudioBuffer`\ s in the `AudioBufferList`
    /// (`mNumberBuffers`).
    var count: Int { get nonmutating set }

    /// The pointer to the wrapped `AudioBufferList`.
    var unsafePointer: UnsafePointer<AudioBufferList> { get }

    /// The pointer to the wrapped `AudioBufferList`.
    var unsafeMutablePointer: UnsafeMutablePointer<AudioBufferList>
}

extension UnsafeMutableAudioBufferListPointer : MutableCollectionType {
    func generate() -> IndexingGenerator<UnsafeMutableAudioBufferListPointer>

    /// Always zero, which is the index of the first `AudioBuffer`.
    var startIndex: Int { get }

    /// The "past the end" position; always identical to `count`.
    var endIndex: Int { get }
    subscript (index: Int) -> AudioBuffer { get nonmutating set }
}
