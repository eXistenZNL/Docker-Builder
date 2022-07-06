<?php

setlocale(LC_ALL, 'nl_NL.UTF-8');

$output = strftime("%A %e %B %Y", mktime(0, 0, 0, 12, 22, 1978));

if ($output !== 'vrijdag 22 december 1978') {
    exit(1);
}
