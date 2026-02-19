#!/usr/bin/env bash

variable="hola"

{ variable="adios"; }

echo "$variable"

contador=0
{ contador=$((contador+1)); }
echo "$contador"


cd /tmp
( cd / )
pwd
