"""FlowForge Claude Code Integration Package."""
__version__ = "2.0.6"

# Import all statusline components for easy access
try:
    from .statusline import *
    from .context_usage_calculator import *
    from .statusline_cache import *
    from .statusline_data_loader import *
    from .statusline_helpers import *
except ImportError:
    # Graceful degradation if some modules are missing
    pass
