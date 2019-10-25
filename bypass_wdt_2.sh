#!/bin/bash
./5174 --bypass bpon 9 1 0
sleep 10
./5174 --bypass  wdt 9 1 1 1
usleep 1200000
./5174 --bypass rbpon 0 1
./5174 --bypass  wdt 9 1 1 1
usleep 1250000
./5174 --bypass rbpon 0 1
./5174 --bypass  wdt 9 1 1 1
usleep 1300000
./5174 --bypass rbpon 0 1
./5174 --bypass  wdt 9 1 1 1
usleep 1310000
./5174 --bypass rbpon 0 1
./5174 --bypass  wdt 9 1 1 1
usleep 1380000
./5174 --bypass rbpon 0 1
./5174 --bypass  wdt 9 1 1 1
usleep 1400000
./5174 --bypass rbpon 0 1
./5174 --bypass  wdt 9 1 1 1
usleep 1500000
./5174 --bypass rbpon 0 1
./5174 --bypass  wdt 9 1 1 1
usleep 1800000
./5174 --bypass rbpon 0 1