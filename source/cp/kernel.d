module cp.kernel;

import cp.session;
import cp.puzzleruntime;

interface IfKernel
{
	@property IfSession session();
	@property IfPuzzleRuntime puzzleRuntime();
}

class Kernel: IfKernel
{
	private static IfKernel[IfSession] _sessionKernelMap;
	private IfSession _session;
	private IfPuzzleRuntime _puzzleRuntime;
	
	@property IfSession session()
	{
		return _session;
	}
	
	@property IfPuzzleRuntime puzzleRuntime()
	{
		return _puzzleRuntime;
	}
	
	private this(IfSession session)
	{
		_session = session;
		_puzzleRuntime = new PuzzleRuntime(_session);
	}
	
	static IfKernel create()
	{
		auto session = new Session();
		return Kernel.create(session);
	}
	
	static IfKernel create(IfSession session)
	{
		assert((session in _sessionKernelMap) is null);
		auto kernel = new Kernel(session);
		_sessionKernelMap[session] = kernel;
		return kernel;
	}
	
	static IfKernel getForSession(IfSession session)
	{
		assert((session in _sessionKernelMap) !is null);
		return _sessionKernelMap[session];
	}
}
