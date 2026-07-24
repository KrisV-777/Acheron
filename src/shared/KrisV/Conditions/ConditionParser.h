// Code originally from DAV (https://github.com/Exit-9B/DynamicArmorVariants)
// Licensed under the MIT License (https://opensource.org/licenses/MIT)
// The code has been modified and adapted for general use

#pragma once

#include "RefMap.h"

namespace Conditions
{
    class ConditionParser
    {
      public:
        ConditionParser() = delete;

        static RE::TESConditionItem* Parse(std::string_view a_text, const RefMap& a_refMap = {});
        static std::shared_ptr<RE::TESCondition> ParseConditions(const std::vector<std::string>& a_rawConditions, const RefMap& a_refMap = {});

      private:
        union ConditionParam
        {
            char c;
            std::int32_t i;
            float f;
            RE::TESForm* form;
            RE::BSString* str;
        };

        static ConditionParam ParseParam(const std::string& a_text, RE::SCRIPT_PARAM_TYPE a_type, const RefMap& a_refMap);
    };
}  // namespace Conditions
