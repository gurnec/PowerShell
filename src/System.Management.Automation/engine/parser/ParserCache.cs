// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace System.Management.Automation.Language
{
    /// <summary>
    /// Provides a cached reusable instance of Parser, per thread.
    /// </summary>
    internal static class ParserCache
    {
        [ThreadStatic]
        private static Parser t_cachedInstance;

        internal static Parser Acquire()
        {
            Parser p = t_cachedInstance;
            if (p != null)
            {
                t_cachedInstance = null;
                return p;
            }

            return new Parser();
        }

        internal static void Release(Parser p)
        {
            if (p.ErrorList.Count > 0)
            {
                p.ErrorList.Clear();
            }

            p._fileName = null;
            p._ungotToken = null;
            t_cachedInstance = p;
        }
    }
}
