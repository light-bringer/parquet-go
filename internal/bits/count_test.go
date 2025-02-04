package bits_test

import (
	"bytes"
	"testing"

	"github.com/segmentio/parquet-go/internal/bits"
)

func TestCountByte(t *testing.T) {
	err := quickCheck(func(data []byte) bool {
		data = bytes.Repeat(data, 8)
		for _, c := range data {
			n1 := bytes.Count(data, []byte{c})
			n2 := bits.CountByte(data, c)
			if n1 != n2 {
				t.Errorf("got=%d want=%d", n2, n1)
				return false
			}
		}
		return true
	})
	if err != nil {
		t.Error(err)
	}
}

func BenchmarkCountByte(b *testing.B) {
	forEachBenchmarkBufferSize(b, func(b *testing.B, bufferSize int) {
		data := make([]byte, bufferSize)
		for i := range data {
			data[i] = byte(i)
		}
		for i := 0; i < b.N; i++ {
			bits.CountByte(data, 0)
		}
	})
}
