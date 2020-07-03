<?php

$output = iconv('UTF-8', 'ASCII//TRANSLIT', 'foobar');

if ($output !== 'foobar') {
    exit(1);
}
