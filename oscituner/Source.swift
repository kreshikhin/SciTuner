
/*
class Source struct{
    OnData func(sample []float64)
    Freq float64

    func init() *Source{
        var f1: Float = 201.625565
        var f2: Float = 0.05
        var dfmax: Float = 30.0
        var Fd: Float = 44100

        var sample = [Float](count: 2205)

        var dt = Float(1) / Fd
        var t: Float = 0

        /*go (func(){
            time.Sleep(time.Second)

            for {
                time.Sleep(time.Second / 20)

                df := dfmax * math.Sin(2 * math.Pi * f2 * t)
                s.Freq = f1 + df

                for i, _ := range sample {
                    t += dt
                    sample[i] = math.Cos(2 * math.Pi * (f1 + df) * t + rand.Float64() / 100) + 0.5 * (rand.Float64() - 0.5)
                }

                if s.OnData != nil {
                    s.OnData(sample)
                }
            }
        })()*/
    }

    func GetFreqText() -> String {
        return fmt.Sprintf("%6.2f Hz", s.Freq)
    }
}

*/