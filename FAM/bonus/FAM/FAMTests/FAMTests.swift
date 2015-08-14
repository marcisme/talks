//
//  FAMTests.swift
//  FAMTests
//
//  Created by Marc Schwieterman on 8/4/15.
//  Copyright (c) 2015 Marc Schwieterman Software, LLC. All rights reserved.
//

import XCTest
import AudioToolbox
import FAM


class FAMTests: XCTestCase {

    func testAudioBufferList() {
        XCTAssertEqual(sizeof(AudioBufferList), 24)
        XCTAssertEqual(alignof(AudioBufferList), 8)
        XCTAssertEqual(strideof(AudioBufferList), 24)
    }

    func testAudioBuffer() {
        XCTAssertEqual(sizeof(AudioBuffer), 16)
        XCTAssertEqual(alignof(AudioBuffer), 8)
        XCTAssertEqual(strideof(AudioBuffer), 16)
    }

    func testUInt32() {
        XCTAssertEqual(sizeof(UInt32), 4)
        XCTAssertEqual(alignof(UInt32), 4)
        XCTAssertEqual(strideof(UInt32), 4)
    }

    func testUInt64() {
        XCTAssertEqual(sizeof(UInt64), 8)
        XCTAssertEqual(alignof(UInt64), 8)
        XCTAssertEqual(strideof(UInt64), 8)
    }

    func testAudioBufferListSizeInBytes() {
        XCTAssertEqual(AudioBufferList.sizeInBytes(maximumBuffers: 2), 40)
    }

    func testStaticArray() {
        let sa = StaticArrayEndowed(staticArray: (1, 2, 3))
        let a: (UInt8, UInt8, UInt8) = sa.staticArray
        let b: [AnyObject] = ReferenceObjects.nsArray()
    }

    func testWrapper() {
        var audioBuffers = [
            AudioBuffer(mNumberChannels: 1, mDataByteSize: 1, mData: buffer([128])),
            AudioBuffer(mNumberChannels: 1, mDataByteSize: 1, mData: buffer([255]))
        ]

        let wrapper = AudioBufferListWrapper(count: 2)
        wrapper[0] = audioBuffers[0]
        wrapper[1] = audioBuffers[1]

        XCTAssertEqual(wrapper.count, 2)
        XCTAssertEqual(wrapper[0].mNumberChannels, 1)
        XCTAssertEqual(wrapper[0].mDataByteSize, 1)
        XCTAssertEqual(UnsafeMutablePointer<UInt8>(wrapper[0].mData).memory, 128)
        XCTAssertEqual(wrapper[1].mNumberChannels, 1)
        XCTAssertEqual(wrapper[1].mDataByteSize, 1)
        XCTAssertEqual(UnsafeMutablePointer<UInt8>(wrapper[1].mData).memory, 255)

        let audioBufferList = UnsafeMutableAudioBufferListPointer(wrapper.audioBufferListPointer)

        XCTAssertEqual(audioBufferList.count, 2)
        XCTAssertEqual(audioBufferList[0].mNumberChannels, 1)
        XCTAssertEqual(audioBufferList[0].mDataByteSize, 1)
        XCTAssertEqual(UnsafeMutablePointer<UInt8>(audioBufferList[0].mData).memory, 128)
        XCTAssertEqual(audioBufferList[1].mNumberChannels, 1)
        XCTAssertEqual(audioBufferList[1].mDataByteSize, 1)
        XCTAssertEqual(UnsafeMutablePointer<UInt8>(audioBufferList[1].mData).memory, 255)
    }

    func testWrapper_v1() {
        var audioBuffers = [
            AudioBuffer(mNumberChannels: 1, mDataByteSize: 1, mData: buffer([128])),
            AudioBuffer(mNumberChannels: 1, mDataByteSize: 1, mData: buffer([255]))
        ]

        let wrapper = AudioBufferListWrapper_v1(audioBuffers: audioBuffers)

        let audioBufferList = UnsafeMutableAudioBufferListPointer(wrapper.audioBufferListPointer)

        XCTAssertEqual(audioBufferList.count, 2)
        XCTAssertEqual(audioBufferList[0].mNumberChannels, 1)
        XCTAssertEqual(audioBufferList[0].mDataByteSize, 1)
        XCTAssertEqual(UnsafeMutablePointer<UInt8>(audioBufferList[0].mData).memory, 128)
        XCTAssertEqual(audioBufferList[1].mNumberChannels, 1)
        XCTAssertEqual(audioBufferList[1].mDataByteSize, 1)
        XCTAssertEqual(UnsafeMutablePointer<UInt8>(audioBufferList[1].mData).memory, 255)
    }

    func testManual() {
        var audioBuffers = [
            AudioBuffer(mNumberChannels: 1, mDataByteSize: 1, mData: buffer([128])),
            AudioBuffer(mNumberChannels: 1, mDataByteSize: 1, mData: buffer([255]))
        ]

        var audioBufferListPointer: UnsafeMutablePointer<AudioBufferList>

        let size = strideof(AudioBufferList) + strideof(AudioBuffer) * (audioBuffers.count - 1)
        let memory = UnsafeMutablePointer<UInt8>.alloc(size)
        
        audioBufferListPointer = UnsafeMutablePointer<AudioBufferList>(memory)
        audioBufferListPointer.memory.mNumberBuffers = UInt32(audioBuffers.count)

        memcpy(&audioBufferListPointer.memory.mBuffers, &audioBuffers, size)

        let audioBufferList = UnsafeMutableAudioBufferListPointer(audioBufferListPointer)

        XCTAssertEqual(audioBufferList.count, 2)
        XCTAssertEqual(audioBufferList[0].mNumberChannels, 1)
        XCTAssertEqual(audioBufferList[0].mDataByteSize, 1)
        XCTAssertEqual(UnsafeMutablePointer<UInt8>(audioBufferList[0].mData).memory, 128)
        XCTAssertEqual(audioBufferList[1].mNumberChannels, 1)
        XCTAssertEqual(audioBufferList[1].mDataByteSize, 1)
        XCTAssertEqual(UnsafeMutablePointer<UInt8>(audioBufferList[1].mData).memory, 255)

        memory.dealloc(size)
    }

    func testReferenceObject() {
        var referenceAudioBufferList = ReferenceObjects.twoBufferListPointer()
        let audioBufferList = UnsafeMutableAudioBufferListPointer(referenceAudioBufferList)
        
        XCTAssertEqual(audioBufferList.count, 2)
        XCTAssertEqual(audioBufferList[0].mNumberChannels, 1)
        XCTAssertEqual(audioBufferList[0].mDataByteSize, 1)
        XCTAssertEqual(UnsafeMutablePointer<UInt8>(audioBufferList[0].mData).memory, 128)
        XCTAssertEqual(audioBufferList[1].mNumberChannels, 1)
        XCTAssertEqual(audioBufferList[1].mDataByteSize, 1)
        XCTAssertEqual(UnsafeMutablePointer<UInt8>(audioBufferList[1].mData).memory, 255)
    }

    func buffer(var bytes: [UInt8]) -> UnsafeMutablePointer<UInt8> {
        var p = UnsafeMutablePointer<UInt8>.alloc(bytes.count)
        p.initializeFrom(bytes)
        return p
    }

}

class AudioBufferListWrapper {

    let count: Int

    var audioBufferListPointer: UnsafeMutablePointer<AudioBufferList>

    private let size: Int
    private let memory: UnsafeMutablePointer<UInt8>
    private let audioBuffers: UnsafeMutableBufferPointer<AudioBuffer>

    init(count: Int) {
        assert(count > 0)
        self.count = count
        self.size = strideof(AudioBufferList) + strideof(AudioBuffer) * (count - 1)

        self.memory = UnsafeMutablePointer<UInt8>.alloc(size)
        audioBufferListPointer = UnsafeMutablePointer<AudioBufferList>(memory)

        audioBufferListPointer.memory.mNumberBuffers = UInt32(count)
        audioBuffers = UnsafeMutableBufferPointer(start: &audioBufferListPointer.memory.mBuffers, count: count)
    }

    deinit {
        memory.dealloc(size)
    }

}

extension AudioBufferListWrapper: MutableCollectionType {

    var startIndex: Int { return 0 }
    var endIndex: Int { return count }

    func generate() -> IndexingGenerator<AudioBufferListWrapper> {
        return IndexingGenerator(self)
    }

    subscript (index: Int) -> AudioBuffer {
        get {
            return audioBuffers[index]
        }
        set {
            audioBuffers[index] = newValue
        }
    }

}

class AudioBufferListWrapper_v1 {

    var audioBufferListPointer: UnsafeMutablePointer<AudioBufferList>

    private let offset = strideof(AudioBufferList) - strideof(AudioBuffer)
    private let size: Int
    private let memory: UnsafeMutablePointer<UInt8>

    init(var audioBuffers: [AudioBuffer]) {
        self.size = offset + strideof(AudioBuffer) * audioBuffers.count
        self.memory = UnsafeMutablePointer<UInt8>.alloc(size)

        audioBufferListPointer = UnsafeMutablePointer<AudioBufferList>(memory)
        audioBufferListPointer.memory.mNumberBuffers = UInt32(audioBuffers.count)

        memcpy(&audioBufferListPointer.memory.mBuffers, &audioBuffers, size)
    }

    deinit {
        memory.dealloc(size)
    }

}

class AudioBufferListWrapper_Apple {

    var audioBufferListPointer: UnsafeMutablePointer<AudioBufferList> {
        return audioBufferList.unsafeMutablePointer
    }

    private let audioBufferList: UnsafeMutableAudioBufferListPointer

    init(var audioBuffers: [AudioBuffer]) {
        audioBufferList = AudioBufferList.allocate(maximumBuffers: audioBuffers.count)
        for i in 0..<audioBuffers.count {
            audioBufferList[i] = audioBuffers[i]
        }
    }

    deinit {
        free(audioBufferListPointer)
    }

}
