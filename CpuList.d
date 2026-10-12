#!/usr/bin/rdmd

import std.stdio:   writeln;
import std.process: wait, spawnShell, executeShell;
import std.string:  startsWith, chompPrefix, chomp;
import core.sys.posix.unistd: geteuid;
import std.file: dirEntries, exists, isDir, SpanMode, readText;
import std.string;
import std.file: readText, chdir;
import std.conv;


bool ensureSuper(string[] args) {
    //If already superuser, return now.
    if (geteuid() == 0) {
        return true;
    }

    //Get this script's name.
    string scriptName = getScriptName(args);
    if (scriptName is null) {
        //The script wasn't run with rdmd (maybe it was compiled with dmd). Use the arg name:
        scriptName = args[0];
    }

    if (scriptName.indexOf("rdmd") != -1) {
        scriptName = "./CpuList.d";
    }

    //Rerun as superuser.
    //Note1: The switch -n prevents sudo from asking for a password.
    //The scriptName should be in sudoers, if it isn't, then don't run it.
    //Note2: system(sudo) returns 1 if it couldn't run, or else forwards the return
    //value of the command (which can also be 1).
    int r = wait(spawnShell("sudo -n " ~ scriptName));
    if (r != 0) {
        writeln("Error: must be run as superuser. Error level: ", r);
    }
    return false;
}


string getScriptName(string[] args) {
    string prefix = "/tmp/.rdmd";

    string name = args[0].idup;
    
    //Remove prefix
    if (!name.startsWith(prefix)) {
        return null;
    }
    name = name.chompPrefix(prefix);
    
    //Remove extension
    size_t dotPos = -1;
    for (size_t i=name.length-1; i >= 0; --i) {
        if (name[i] == '.') {
            dotPos = i;
            break;
        }
    }
    if (dotPos == -1) {
        return null;
    }

    return name[0 .. dotPos];
}


//How many cpu[0-9] directories are there (cores). It supports 'cpu12' with two numbers:
int detectCores() {
    int cores = 0;
    foreach (string filename; dirEntries("/sys/devices/system/cpu", SpanMode.shallow)) {
        string subdir = filename ~ "/cpufreq/";
        if (exists(subdir) && isDir(subdir)) {
            ++cores;
        }
    }
    return cores;
}

//Example, from 
//   3501000 3500000 3300000 3100000 2900000 2700000 2500000 2300000 2100000 2000000 1800000 1600000 1400000 1200000 1000000 800000 
//it returns the FIRST one:
//   3501000
string detectMaxCpuFrequency() {
    string s = strip(readText("/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies"));
    string[] list = split(s);
    return list[0];
}

//Example, from 
//   3501000 3500000 3300000 3100000 2900000 2700000 2500000 2300000 2100000 2000000 1800000 1600000 1400000 1200000 1000000 800000 
//it returns the second one:
//   3500000
string detectMaxNonTurboFrequency() {
    string s = strip(readText("/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies"));
    string[] list = split(s);
    return list[1];
}

//Useful to customize the script for each laptop, PC, or home TV computer:
string getHostname() {
    return strip(executeShell("hostname").output);
}


int main (string[] args)
{
    if (!ensureSuper(args)) {return 1;}

    //Listar clock maximo y clock actual.
    chdir("/sys/devices/system/cpu/");
    immutable CORES = detectCores();
    foreach (int i; 0 .. CORES) {
        writeln("cpu"~to!string(i)~" scaling_governor: " ~ chomp(readText("cpu"~to!string(i)~"/cpufreq/scaling_governor")));
    }
    foreach (int i; 0 .. CORES) {
        writeln("cpu"~to!string(i)~" scaling_min_freq: " ~ chomp(readText("cpu"~to!string(i)~"/cpufreq/scaling_min_freq")));
    }
    foreach (int i; 0 .. CORES) {
        writeln("cpu"~to!string(i)~" scaling_max_freq: " ~ chomp(readText("cpu"~to!string(i)~"/cpufreq/scaling_max_freq")));
    }
    foreach (int i; 0 .. CORES) {
        //writeln("Clock CPU"~to!string(i)~": " ~ chomp(readText("cpu"~to!string(i)~"/cpufreq/cpuinfo_cur_freq")));
        writeln("Clock CPU"~to!string(i)~": " ~ chomp(readText("cpu"~to!string(i)~"/cpufreq/scaling_cur_freq")));
    }

    return 0;
}

