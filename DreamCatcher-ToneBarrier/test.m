//
//  test.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/8/20.
//

#import "test.h"

typedef double (^Randomizer)(void);
typedef double (^Distributor)(Randomizer);
typedef Distributor (^Calculator)(double, double);
                
@implementation test
{
    Randomizer randomizer;
    Distributor distributor;
    Calculator calculator;
}

// a block returns a double given two doubles
// it needs a block that tells it how to process the two doubles to return the double in conjunction with a double it needs
// that block needs a block that supplies the double it needs to use with the two it already has

// the caller should only have to specify the two calculation related blocks plus the two doubles:
// double result = calc(double, double, double block(block)(double, double));
//

- (void)test
{
    // Distributor takes a double from Randomizer and returns a double as a value
    // Fandomizer takes nothing and returns a double when called
    
    ^ double (double distributed, double duration) {
        return distributed * duration;
    } (^ double (double random, double gamma) {
        return pow(random, gamma);
    } (^ double (uint32_t m, uint32_t n) {
        return ((drand48() * (m - n)) + n);
    } (400, 2000), 3.0), ^ double (double tally) {
        return tally;
    } (2.0));
}

@end
