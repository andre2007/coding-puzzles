module cp.app;

import cp.cmdline;
import cp.kernel;
import cp.session;

version(unittest)
{
    int main(string[] args)
    {
        return 0;
    }
}
else
{
    IfKernel _kernel;

    int main(string[] args)
    {
        _kernel = Kernel.create();
        return new CommandLine(_kernel.session).execute(args[1..$]);
    }
}

