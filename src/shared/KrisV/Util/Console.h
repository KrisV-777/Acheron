#pragma once

namespace Util
{
    inline void PrintConsole(const std::string& a_str)
    {
        const auto console = RE::ConsoleLog::GetSingleton();
        if (a_str.empty())
            return;
        else if (a_str.size() < 1000)
            console->Print(a_str.data());
        else {  // Large strings printed to console crash the game - truncate it
            size_t i = 0;
            do {
                constexpr auto maxchar = 950;
                auto print = a_str.substr(i, i + maxchar);
                print += '\n';
                i += maxchar;
                console->Print(print.data());
            } while (i < a_str.size());
        }
    }

    template <typename... Args>
    inline void PrintConsole(const std::format_string<Args...> fmt, Args&&... args)
    {
        const auto msg = std::format(fmt, std::forward<Args>(args)...);
        RE::ConsoleLog::GetSingleton()->Print(msg);
    }
}