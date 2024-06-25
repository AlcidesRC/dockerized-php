<?php

declare(strict_types=1);

namespace Tests\Unit\Providers;

use App\Providers\Foo;
use PHPUnit\Framework\Attributes\CoversClass;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\Attributes\Test;
use PHPUnit\Framework\TestCase;
use SlopeIt\ClockMock\ClockMock;

#[CoversClass(Foo::class)]
final class FooTest extends TestCase
{
    protected function setUp(): void
    {
        ClockMock::freeze(new \DateTime('2023-01-01 00:00:00'));
    }

    protected function tearDown(): void
    {
        ClockMock::reset();
    }

    #[Test]
    #[DataProvider('dataProviderForDump')]
    public function checkInvokeMethod(string $expectedLog): void
    {
        $this->assertEquals($expectedLog, Foo::dump());
    }

    /**
     * @return array<string, array<int, string>>
     */
    public static function dataProviderForDump(): array
    {
        return [
            '[DEFAULT CASE]' => [
                '[01-Jan-2023 00:00:00] App\Providers\Foo: Executed method [ dump ] in [ DEVELOPMENT ] mode' . PHP_EOL,
            ],
        ];
    }
}
