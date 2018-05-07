<?php
echo "DIST\n";
if (!isset($argv[1])) die("NO FILE DEFINED\n");
$fh = fopen($argv[1], "r");
if ($fh) {
    $multi = bcpow("10", "18");
    echo "//".str_replace(".CSV", "", strtoupper($argv[1]))."\n";
    $contract = 1;
    $counter = 1;
    $stake_total = "0";
    $stake_super_total = "0";
    while (($line = fgets($fh)) !== false) {
        $parts = explode("-", $line);
        $stake = bcmul(trim(array_values(array_slice($parts, 1))[0]), $multi);
        $address = trim(array_values(array_slice($parts, 0))[0]);
        if ($stake > 0 && strlen($address)==42 && substr($address, 0, 2)=="0x") {
            $stake_total = bcadd($stake_total, $stake);
            $stake_super_total = bcadd($stake_super_total, $stake);
            if ($counter==80) {
                echo "---------------------------------END CONTRACT ".$contract." TOTAL: ".bcdiv($stake_total, $multi)."\n";
                $stake_total = "0";
                $contract++;
                $counter = 1;
            }
            echo "        pearl.transfer(".$address.", ".$stake.");\n";
            $counter++;
        }
    }
    fclose($fh);
    echo "---------------------------------END CONTRACT ".$contract." TOTAL: ".bcdiv($stake_total, $multi)."\n";
    echo "SUPER TOTAL: ".bcdiv($stake_super_total, $multi)."\n";
}
else die("HANDLE ERROR\n");