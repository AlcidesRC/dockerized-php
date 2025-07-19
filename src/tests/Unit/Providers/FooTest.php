<?php

declare(strict_types=1);

namespace UnitTests\Providers;

use App\Providers\Foo;
use DateTimeImmutable;
use PHPUnit\Framework\Attributes\CoversClass;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\Attributes\Test;
use PHPUnit\Framework\TestCase;

#[CoversClass(Foo::class)]
final class FooTest extends TestCase
{
    #[Test]
    #[DataProvider('dataProviderForGetDateTime')]
    public function checkGetDateTime(string $format): void
    {
        $datetime = new DateTimeImmutable();

        self::assertEquals($datetime->format($format), Foo::getDateTime($format));
    }

    /**
     * @return array<string, array<int, string>>
     */
    public static function dataProviderForGetDateTime(): array
    {
        $datetime = new DateTimeImmutable();

        return [
            '[CURRENT DATE TIME]' => [$datetime->format('Y-m-d H:i:s')],
            '[CURRENT DATE]' => [$datetime->format('Y-m-d')],
            '[CURRENT TIME]' => [$datetime->format('H:i:s')],
        ];
    }

    #[Test]
    public function checkMockFinalClass(): void
    {
        $instance = new Foo();

        self::assertEquals('pong', $instance->ping());

        $mock = $this->createMock(get_class($instance));
        $mock->expects(self::once())->method('ping')->willReturn('knock knock');

        self::assertEquals('knock knock', $mock->ping());
    }
}
