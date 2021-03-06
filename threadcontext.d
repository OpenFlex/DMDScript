/* Digital Mars DMDScript source code.
 * Copyright (c) 2000-2002 by Chromium Communications
 * D version Copyright (c) 2004-2010 by Digital Mars
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
 * written by Walter Bright
 * http://www.digitalmars.com
 *
 * DMDScript is implemented in the D Programming Language,
 * http://www.digitalmars.com/d/
 *
 * For a C++ implementation of DMDScript, including COM support, see
 * http://www.digitalmars.com/dscript/cppscript.html
 */


module dmdscript.threadcontext;

import std.thread;

alias std.thread.Thread Thread;

import dmdscript.script;
import dmdscript.program;
import dmdscript.dmath;
import dmdscript.dobject;
import dmdscript.dfunction;

// These are our per-thread global variables

struct ThreadContext
{
    Thread threadid;    // identifier of current thread

    // Tables where the prototype and constructor object are stored.
    Dobject[d_string] protoTable;
    Dfunction[d_string] ctorTable;

    // Table where object initializers go
    static void function(ThreadContext*)[] initTable;

    // Values from here to the end of the struct are 0'd by dobject_term()
    Program program;    // associated data

    Dfunction Dobject_constructor;
    Dobject Dobject_prototype;

    Dfunction Dfunction_constructor;
    Dobject Dfunction_prototype;

    Dfunction Darray_constructor;
    Dobject Darray_prototype;

    Dfunction Dstring_constructor;
    Dobject Dstring_prototype;

    Dfunction Dboolean_constructor;
    Dobject Dboolean_prototype;

    Dfunction Dnumber_constructor;
    Dobject Dnumber_prototype;

    Dfunction Derror_constructor;
    Dobject Derror_prototype;

    Dfunction Ddate_constructor;
    Dobject Ddate_prototype;

    Dfunction Dregexp_constructor;
    Dobject Dregexp_prototype;

    Dfunction Denumerator_constructor;
    Dobject Denumerator_prototype;

    Dmath Dmath_object;

    /***********************************************
     * Get ThreadContext associated with this thread.
     */

    static ThreadContext[Thread] threadtable;

    static Thread cache_ti;
    static ThreadContext* cache_cc;

    static ThreadContext* getThreadContext()
    {
        /* This works by creating an array of ThreadContext's, one
         * for each thread. We match up by thread id.
         */

        Thread ti;
        ThreadContext *cc;

        //writef("ThreadContext.getThreadContext()\n");

        ti = Thread.getThis();

        synchronized
        {
            // Used cached version if we can
            if (ti == cache_ti)
            {
                cc = cache_cc;
                //exception(L"getThreadContext(): cache x%x", ti);
            }
            else
            {
                cc = ti in threadtable;
                if (!cc)
                {
                    threadtable[ti] = ThreadContext.init;
                    cc = &threadtable[ti];
                }

                cc.threadid = ti;

                // Cache for next time
                cache_ti = ti;
                cache_cc = cc;
            }
        }
        return cc;
    }
}


