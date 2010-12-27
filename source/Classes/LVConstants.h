#import "LVInstrumentationController.h"

#define LVLog(formatString,...){ \
[LVInstrumentationController logWithFormat:(formatString), ## __VA_ARGS__]; \
}

#define LVLogInfo(formatString,...){ \
[LVInstrumentationController logWithFormat:(formatString), ## __VA_ARGS__]; \
}

#define LVLogWarning(formatString,...){ \
[LVInstrumentationController logWithFormat:(formatString), ## __VA_ARGS__]; \
}

#define LVLogError(formatString,...){ \
[LVInstrumentationController logWithFormat:(formatString), ## __VA_ARGS__]; \
}

