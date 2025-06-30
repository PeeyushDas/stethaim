import 'dart:convert';
import 'dart:typed_data';

class WavHeader {
  /// Converts a string to its ASCII byte representation.
  static Uint8List toBytes(String str) {
    return ascii.encode(str);
  }

  /// Creates a WAV file header for PCM format.
  ///
  /// [wavSize] is the size of the raw audio data.
  /// The header size is always 44 bytes, so the total file size is [wavSize] + 44.
  static List<int> createWavHeader(int wavSize) {
    List<int> header = [];

    // 1. Chunk ID "RIFF"
    Uint8List chunkId = toBytes('RIFF');
    ByteData chunkIdData = chunkId.buffer.asByteData();
    for (int i = 0; i < 4; i++) {
      header.add(chunkIdData.getUint8(i));
    }

    // 2. Chunk Size: fileSize = wavSize + 44 - 8
    int fileSize = wavSize + 44 - 8;
    ByteData chunkSize = ByteData(4);
    chunkSize.setUint32(0, fileSize, Endian.little);
    for (int i = 0; i < 4; i++) {
      header.add(chunkSize.getUint8(i));
    }

    // 3. Format: "WAVEfmt "
    Uint8List waveFmt = toBytes('WAVEfmt ');
    ByteData waveFmtData = waveFmt.buffer.asByteData();
    for (int i = 0; i < 8; i++) {
      header.add(waveFmtData.getUint8(i));
    }

    // 4. Subchunk1 Size: 16 for PCM
    ByteData subChunk1Size = ByteData(4);
    subChunk1Size.setUint32(0, 16, Endian.little);
    for (int i = 0; i < 4; i++) {
      header.add(subChunk1Size.getUint8(i));
    }

    // 5. Audio Format: 1 for PCM
    ByteData audioFormat = ByteData(2);
    audioFormat.setUint16(0, 1, Endian.little);
    for (int i = 0; i < 2; i++) {
      header.add(audioFormat.getUint8(i));
    }

    // 6. Number of Channels: 1 (mono)
    ByteData numChannels = ByteData(2);
    numChannels.setUint16(0, 1, Endian.little);
    for (int i = 0; i < 2; i++) {
      header.add(numChannels.getUint8(i));
    }

    // 7. Sample Rate: 16000 Hz
    ByteData sampleRate = ByteData(4);
    sampleRate.setUint32(0, 16000, Endian.little);
    for (int i = 0; i < 4; i++) {
      header.add(sampleRate.getUint8(i));
    }

    // 8. Byte Rate = SampleRate * NumChannels * BitsPerSample/8
    //    For 16-bit mono: 16000 * 1 * 16/8 = 32000
    ByteData byteRate = ByteData(4);
    byteRate.setUint32(0, 32000, Endian.little);
    for (int i = 0; i < 4; i++) {
      header.add(byteRate.getUint8(i));
    }

    // 9. Block Align = NumChannels * BitsPerSample/8, for mono = 2
    ByteData blockAlign = ByteData(2);
    blockAlign.setUint16(0, 2, Endian.little);
    for (int i = 0; i < 2; i++) {
      header.add(blockAlign.getUint8(i));
    }

    // 10. Bits Per Sample: 16
    ByteData bitsPerSample = ByteData(2);
    bitsPerSample.setUint16(0, 16, Endian.little);
    for (int i = 0; i < 2; i++) {
      header.add(bitsPerSample.getUint8(i));
    }

    // 11. Data Subchunk ID: "data"
    Uint8List dataId = toBytes('data');
    ByteData dataIdData = dataId.buffer.asByteData();
    for (int i = 0; i < 4; i++) {
      header.add(dataIdData.getUint8(i));
    }

    // 12. Data Subchunk Size: wavSize
    ByteData dataSize = ByteData(4);
    dataSize.setUint32(0, wavSize, Endian.little);
    for (int i = 0; i < 4; i++) {
      header.add(dataSize.getUint8(i));
    }

    print("*** MADE header length = ${header.length}");
    return header;
  }
}
