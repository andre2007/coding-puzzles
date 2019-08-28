module cp.app;

import cp.cmdline;
import cp.kernel;
import cp.session;

IfKernel _kernel;

int main(string[] args)
{
	_kernel = Kernel.create();
	
	return new CommandLine(_kernel.session).execute(args[1..$]);
}
