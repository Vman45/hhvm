<?hh

function my_autoload($class) {
  var_dump($class);
  if ($class == 'A')
    $test = class_exists('C');
  if ($class == 'A') {
    include 'spl_autoload_chained_A.inc';
    $b = new B();
  }
  if ($class == 'B') {
    include 'spl_autoload_chained_B.inc';
    $c = new C();
  }
  if ($class == 'C') {
    include 'spl_autoload_chained_C.inc';
  }
}


<<__EntryPoint>>
function main_spl_autoload_chained2() {
spl_autoload_register('my_autoload');

$a = new A();
}
