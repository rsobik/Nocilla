#import "LSStubResponse.h"

@interface LSStubResponse ()
@property (nonatomic, assign, readwrite) NSInteger statusCode;
@property (nonatomic, strong) NSMutableDictionary *mutableHeaders;
@property (nonatomic, assign) UInt64 offset;
@property (nonatomic, assign, getter = isDone) BOOL done;
@end

@implementation LSStubResponse

#pragma Initializers
- (id)initDefaultResponse {
    self = [super init];
    if (self) {
        self.statusCode = 200;
        self.mutableHeaders = [NSMutableDictionary dictionary];
        self.body = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

-(id)initWithStatusCode:(NSInteger)statusCode {
    self = [super init];
    if (self) {
        self.statusCode = statusCode;
        self.mutableHeaders = [NSMutableDictionary dictionary];
        self.body = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

- (id)initWithRawResponse:(NSData *)rawResponseData {
    self = [self initDefaultResponse];
    if (self) {
        CFHTTPMessageRef httpMessage = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, FALSE);
        if (httpMessage) {
            CFHTTPMessageAppendBytes(httpMessage, [rawResponseData bytes], [rawResponseData length]);
            
            self.body = rawResponseData; // By default
            
            if (CFHTTPMessageIsHeaderComplete(httpMessage)) {
                self.statusCode = (NSInteger)CFHTTPMessageGetResponseStatusCode(httpMessage);
                self.mutableHeaders = [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSDictionary *)CFHTTPMessageCopyAllHeaderFields(httpMessage)];
                self.body = (__bridge_transfer NSData *)CFHTTPMessageCopyBody(httpMessage);
            }
            CFRelease(httpMessage);
        }
    }
    return self;
}

- (void)setHeader:(NSString *)header value:(NSString *)value {
    [self.mutableHeaders setValue:value forKey:header];
}
- (NSDictionary *)headers {
    return [NSDictionary dictionaryWithDictionary:self.mutableHeaders];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"StubRequest:\nStatus Code: %d\nHeaders: %@\nBody: %@",
            (int)self.statusCode,
            self.mutableHeaders,
            self.body];
}
@end
