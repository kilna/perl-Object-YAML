package TestGlob;

use FindBin;
use Object::YAML::Glob '-base',
    { 'glob' => $FindBin::Bin.'/test_dir/*.yml' };

#sub glob { $FindBin::Bin.'/test_dir/*.yml' }


1;
