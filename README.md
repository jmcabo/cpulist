# cpulist
CpuList and CpuFreq two great little utils I wrote for managing intel CPU speed and temp. The names are not so originals.

Example run:

        $ CpuList
        cpu0 scaling_governor: performance
        cpu1 scaling_governor: performance
        cpu2 scaling_governor: performance
        cpu3 scaling_governor: performance
        cpu4 scaling_governor: performance
        cpu5 scaling_governor: performance
        cpu6 scaling_governor: performance
        cpu7 scaling_governor: performance
        cpu0 scaling_min_freq: 400000
        cpu1 scaling_min_freq: 400000
        cpu2 scaling_min_freq: 400000
        cpu3 scaling_min_freq: 400000
        cpu4 scaling_min_freq: 400000
        cpu5 scaling_min_freq: 400000
        cpu6 scaling_min_freq: 400000
        cpu7 scaling_min_freq: 400000
        cpu0 scaling_max_freq: 3400000
        cpu1 scaling_max_freq: 3400000
        cpu2 scaling_max_freq: 3400000
        cpu3 scaling_max_freq: 3400000
        cpu4 scaling_max_freq: 3400000
        cpu5 scaling_max_freq: 3400000
        cpu6 scaling_max_freq: 3400000
        cpu7 scaling_max_freq: 3400000
        Clock CPU0: 3399965
        Clock CPU1: 3400000
        Clock CPU2: 3400000
        Clock CPU3: 3400000
        Clock CPU4: 3400000
        Clock CPU5: 3399965
        Clock CPU6: 3399965
        Clock CPU7: 3400000
        nadie@tina:~$ 

Use also turbostat to know the precise CPU speed, temperature and watts:

        nadie@tina:~$ 
        nadie@tina:~$ sudo turbostat -S -q --show Bzy_MHz,CPU%c1,CoreTmp,PkgTmp,PkgWatt,CorWatt,GFXWatt   #turbostat
        [sudo] password for nadie: 
        Bzy_MHz CPU%c1  CoreTmp PkgTmp  PkgWatt CorWatt GFXWatt
        3390    24.76   65      65      11.75   9.94    0.08
        3394    15.01   65      65      13.03   11.23   0.06
        3382    24.49   66      66      12.00   10.21   0.05
        3391    15.40   66      66      12.95   11.21   0.02
        3400    0.00    66      66      14.90   13.08   0.05
        3400    0.00    68      68      15.37   13.40   0.15
        3400    0.00    67      67      15.52   13.52   0.15
        3400    0.00    68      68      15.42   13.48   0.10
        3400    0.00    70      70      15.59   13.58   0.14
        3400    0.00    68      68      15.70   13.71   0.12
        3380    28.72   66      66      12.48   10.46   0.14
        3377    47.51   67      67      9.80    7.93    0.07
        3383    36.28   67      67      11.05   9.14    0.09
        3392    24.33   67      67      12.11   10.23   0.07
        3389    12.95   68      68      14.65   12.57   0.19
        3381    20.87   67      67      13.85   11.71   0.25
        3387    13.90   68      68      14.54   12.30   0.30
        3400    0.00    65      66      15.45   13.41   0.15
        3400    0.00    67      66      16.40   14.15   0.30
        3400    0.00    71      72      16.07   14.03   0.20
        3400    0.00    75      74      18.71   16.55   0.23
        ^C3400  0.00    75      75      18.96   16.86   0.17
        nadie@tina:~$ 

I fixed the speed to 3.4GHz using CpuFreq:

        root@tina:/home/nadie# CpuFreq 
        Current frequency: 3400000 KHz
        Current governor: performance
        Available frequencies: 4200000 4100000 4000000 3900000 3800000 3700000 3600000 3500000 3400000 3300000 3200000 3100000 3000000 2900000 2800000 2700000 2600000 2500000 2400000 2300000 2200000 2100000 2000000 1900000 1800000 1700000 1600000 1500000 1400000 1300000 1200000 1100000 1000000 900000 800000 700000 600000 500000 400000
        Available governors: performance powersave
        root@tina:/home/nadie# 

        
        root@tina:/home/nadie# CpuFreq 34  --performance
        Current frequency: 3400000 KHz
        Current governor: performance
        Setting cores to 3400000 KHz
        Found 8 CPUs........ ........
        CPUs governors set to performance
        CPUs set to 3400000 KHz
        root@tina:/home/nadie# 
        root@tina:/home/nadie# 

The programs I used to stimulate the CPU are my stupid find prime number benchmarks which I did run on all CPUs I could find, including my cell phone, my router, Commodore 64 emulator and my HP48GX and HP50g calculators:

        nadie@tina:~$ while true; do ~/admin/scripts/benchmark/benchmark.c 904500; sleep 10; done    #benchmark90
        Elapsed: 55.225s
        71588 prime numbers were found between 2 and 904500
        Elapsed: 54.968s
        71588 prime numbers were found between 2 and 904500
        Elapsed: 55.160s
        71588 prime numbers were found between 2 and 904500
        Elapsed: 54.985s
        71588 prime numbers were found between 2 and 904500
        Elapsed: 55.031s
        71588 prime numbers were found between 2 and 904500

That one is a very soft benchmark, very light on the CPU. It only uses one core. It is single threaded. You can use up all 4, 8 or however many cores you have by running it on 8 consoles at a time, or by launching it with a loop and the nohup command or an ampersand &.

Ohhh, you might prefer the schedutil governor. In that case, intel_pstate=disabled must be passed to grub. For that, a file in /etc/default/grub.d/ cpufreq_driver_intelpstate_disable_jmc.cfg file can be created:

        nadie@tina:/etc/default$ cat grub.d/cpufreq_driver_intelpstate_disable_jmc.cfg 
        #Added by JMC (para tener ondemand/powersave/performance):
        #The intel_pstate=disable is for using CpuFreq:
        GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX  intel_pstate=disable"
        nadie@tina:/etc/default$ 

and don't forget to call sudo update-grub after that:

        sudo update-grub

but if the available frequencies don't include 3.4GHz, then it's preferred to go without schedutil and use the performance driver of intel pstates instead. That may happen in laptops which don't reach 3.4GHz without turbo, that is, it's higher than their nominal speed.

Good luck!

--JMC 2026-10-11

Supplementary files:
A) 
      the lenovo_fix_coil_whine.c file comes from a PDF called "Controlling Processor C-State
Usage in Linux" by Stuart Hayes from Nov2013.
      When started for instance with 250 as parameter, it makes the CPU stay in C0 and C1 never reaching C7. Which might be desirable under cool conditions to prevent the laptop charger and internal PSU go into GREEN MODE, which is switching frequency in the audible range, which is insane if you ask me, completely insane.
      Run it like so:

                 /usr/local/bin/lenovo_fix_coil_whine 250

B)
      The benchmark.c is part of another repo of mine, with a simple loop that forces the CPU to go round and round, it is basically a loop on the IDIV intel assembly language instruction.

Cheers!
Good Luck!

--jm

