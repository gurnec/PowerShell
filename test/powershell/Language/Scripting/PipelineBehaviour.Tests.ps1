Describe 'Function Pipeline Behaviour' -Tag 'CI' {

    BeforeAll {

    }

    Context 'Output from Named Blocks' {

        $Cases = @(
            @{ Script = { begin { 10 } }; ExpectedResult = 10 }
            @{ Script = { process { 15 } }; ExpectedResult = 15 }
            @{ Script = { end { 22 } }; ExpectedResult = 22 }
            @{ Script = { dispose { 11 } }; ExpectedResult = 11 }
        )
        It 'permits output from named block: <Script>' -TestCases $Cases {
            param($Script, $ExpectedResult)

            & $Script | Should -Be $ExpectedResult
        }

        It 'passes output for begin, then process, then end, then dispose' {
            $Script = {
                process { "PROCESS" }
                dispose { "DISPOSE" }
                begin { "BEGIN" }
                end { "END" }
            }

            & $Script | Should -Be @( "BEGIN", "PROCESS", "END", "DISPOSE" )
        }

    }

    Context 'Output Behaviour on Error States' {

        It 'does not execute End {} if the pipeline is halted during Process {}' {
            # We don't need Should -Not -Throw as if this reaches end{} and throws the test will fail anyway.
            1..10 | & {
                begin { "BEGIN" }
                process { "PROCESS $_" }
                end { "END"; throw "This should not be reached." }
            } | Select-Object -First 3 | Should -Be @( "BEGIN", "PROCESS 1", "PROCESS 2" )
        }

        It 'still executes Dispose {} if the pipeline is halted' {
            {
                1..10 | & {
                    process { $_ }
                    dispose { throw "Dispose block hit." }
                } | Select-Object -First 1
            } | Should -Throw -ExpectedMessage "Dispose block hit."
        }

        It 'does not pass output from Dispose {} if the pipeline is halted' {
            1..10 | & {
                process { $_ }
                dispose { "DISPOSE" }
            } | Select-Object -First 5 |
                Should -Be @( 1, 2, 3, 4, 5 )
        }
    }

    AfterAll {

    }
}
