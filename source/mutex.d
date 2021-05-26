module mutex;
import core.thread;
import core.time;

extern(C) {
    private {
        void _miwrite(ulong value) {
            asm { "msr s3_5_c15_c10_1, %0" : : "r"(value); };
        }

        ulong _miread() {
            ulong val;
            asm { "mrs %0, s3_5_c15_c10_1" : "=r"(val); };
            return val;
        }
    }

    /**
        Locks mutex
    */
    void miMutexLock() {
        while (_miread() != 0) { Thread.sleep(10.dur!"nsecs"); }
        _miwrite(1);
    }

    /**
        Clears mutex
    */
    void miMutexUnlock() {
        _miwrite(0);
    }
}

unittest {
    import std.stdio : writeln;
    int test = 0;

    foreach(i; 0..10) {
        new Thread({
            int ix = i;
            foreach(y; 0..10) {
                miMutexLock();
                test++;
                writeln(test, " ", ix, " ", y);
                miMutexUnlock();
            }
        }).start();
    }
}