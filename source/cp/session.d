module cp.session;

import cp.base.logging;


interface IfSession
{
    @property IfLogger logger();
}

class Session : IfSession
{
    private IfLogger _logger;
    
    this()
    {
        _logger = new Logger();
    }
    
    @property IfLogger logger()
    {
        return _logger;
    }
}

