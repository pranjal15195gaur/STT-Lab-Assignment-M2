.. _aiohttp-client-tracing-reference:

Tracing Reference
=================

.. currentmodule:: aiohttp

.. versionadded:: 3.0

A reference for client tracing API.

.. seealso:: :ref:`aiohttp-client-tracing` for tracing usage instructions.


Request life cycle
------------------

A request goes through the following stages and corresponding fallbacks.


Overview
^^^^^^^^

.. graphviz::

   digraph {

     start[shape=point, xlabel="start", width="0.1"];
     redirect[shape=box];
     end[shape=point, xlabel="end  ", width="0.1"];
     exception[shape=oval];

     acquire_connection[shape=box];
     headers_received[shape=box];
     headers_sent[shape=box];
     chunk_sent[shape=box];
     chunk_received[shape=box];

     start -> acquire_connection;
     acquire_connection -> headers_sent;
     headers_sent -> headers_received;
     headers_sent -> chunk_sent;
     chunk_sent -> chunk_sent;
     chunk_sent -> headers_received;
     headers_received -> chunk_received;
     chunk_received -> chunk_received;
     chunk_received -> end;
     headers_received -> redirect;
     headers_received -> end;
     redirect -> headers_sent;
     chunk_received -> exception;
     chunk_sent -> exception;
     headers_sent -> exception;

   }

.. list-table::
   :header-rows: 1

   * - Name
     - Description
   * - start
     - on_request_start
   * - redirect
     - on_request_redirect
   * - acquire_connection
     - Connection acquiring
   * - headers_received
     -
   * - exception
     - on_request_exception
   * - end
     - on_request_end
   * - headers_sent
     - on_request_headers_sent
   * - chunk_sent
     - on_request_chunk_sent
   * - chunk_received
     - on_response_chunk_received

Connection acquiring
^^^^^^^^^^^^^^^^^^^^

.. graphviz::

   digraph {

     begin[shape=point, xlabel="begin", width="0.1"];
     end[shape=point, xlabel="end ", width="0.1"];
     exception[shape=oval];

     queued_start[shape=box];
     queued_end[shape=box];
     create_start[shape=box];
     create_end[shape=box];
     reuseconn[shape=box];
     resolve_dns[shape=box];
     sock_connect[shape=box];

     begin -> reuseconn;
     begin -> create_start;
     create_start -> resolve_dns;
     resolve_dns -> exception;
     resolve_dns -> sock_connect;
     sock_connect -> exception;
     sock_connect -> create_end -> end;
     begin -> queued_start;
     queued_start -> queued_end;
     queued_end -> reuseconn;
     queued_end -> create_start;
     reuseconn -> end;

   }

.. list-table::
   :header-rows: 1

   * - Name
     - Description
   * - begin
     -
   * - end
     -
   * - queued_start
     - on_connection_queued_start
   * - create_start
     - on_connection_create_start
   * - reuseconn
     - on_connection_reuseconn
   * - queued_end
     - on_connection_queued_end
   * - create_end
     - on_connection_create_end
   * - exception
     - Exception raised
   * - resolve_dns
     - DNS resolving
   * - sock_connect
     - Connection establishment

DNS resolving
^^^^^^^^^^^^^

.. graphviz::

   digraph {

     begin[shape=point, xlabel="begin", width="0.1"];
     end[shape=point, xlabel="end", width="0.1"];
     exception[shape=oval];

     resolve_start[shape=box];
     resolve_end[shape=box];
     cache_hit[shape=box];
     cache_miss[shape=box];

     begin -> cache_hit -> end;
     begin -> cache_miss -> resolve_start;
     resolve_start -> resolve_end -> end;
     resolve_start -> exception;

   }

.. list-table::
   :header-rows: 1

   * - Name
     - Description
   * - begin
     -
   * - end
     -
   * - exception
     - Exception raised
   * - resolve_end
     - on_dns_resolvehost_end
   * - resolve_start
     - on_dns_resolvehost_start
   * - cache_hit
     - on_dns_cache_hit
   * - cache_miss
     - on_dns_cache_miss

Classes
-------

.. class:: TraceConfig(trace_config_ctx_factory=SimpleNamespace)

   Trace config is the configuration object used to trace requests
   launched by a :class:`ClientSession` object using different events
   related to different parts of the request flow.

   :param trace_config_ctx_factory: factory used to create trace contexts,
      default class used :class:`types.SimpleNamespace`

   .. method:: trace_config_ctx(trace_request_ctx=None)

      :param trace_request_ctx: Will be used to pass as a kw for the
        ``trace_config_ctx_factory``.

      Build a new trace context from the config.

   Every signal handler should have the following signature::

      async def on_signal(session, context, params): ...

   where ``session`` is :class:`ClientSession` instance, ``context`` is an
   object returned by :meth:`trace_config_ctx` call and ``params`` is a
   data class with signal parameters. The type of ``params`` depends on
   subscribed signal and described below.

   .. attribute:: on_request_start

      Property that gives access to the signals that will be executed
      when a request starts.

      ``params`` is :class:`aiohttp.TraceRequestStartParams` instance.

   .. attribute:: on_request_chunk_sent


      Property that gives access to the signals that will be executed
      when a chunk of request body is sent.

      ``params`` is :class:`aiohttp.TraceRequestChunkSentParams` instance.

      .. versionadded:: 3.1

   .. attribute:: on_response_chunk_received


      Property that gives access to the signals that will be executed
      when a chunk of response body is received.

      ``params`` is :class:`aiohttp.TraceResponseChunkReceivedParams` instance.

      .. versionadded:: 3.1

   .. attribute:: on_request_redirect

      Property that gives access to the signals that will be executed when a
      redirect happens during a request flow.

      ``params`` is :class:`aiohttp.TraceRequestRedirectParams` instance.

   .. attribute:: on_request_end

      Property that gives access to the signals that will be executed when a
      request ends.

      ``params`` is :class:`aiohttp.TraceRequestEndParams` instance.

   .. attribute:: on_request_exception

      Property that gives access to the signals that will be executed when a
      request finishes with an exception.

      ``params`` is :class:`aiohttp.TraceRequestExceptionParams` instance.

   .. attribute:: on_connection_queued_start

      Property that gives access to the signals that will be executed when a
      request has been queued waiting for an available connection.

      ``params`` is :class:`aiohttp.TraceConnectionQueuedStartParams`
      instance.

   .. attribute:: on_connection_queued_end

      Property that gives access to the signals that will be executed when a
      request that was queued already has an available connection.

      ``params`` is :class:`aiohttp.TraceConnectionQueuedEndParams`
      instance.

   .. attribute:: on_connection_create_start

      Property that gives access to the signals that will be executed when a
      request creates a new connection.

      ``params`` is :class:`aiohttp.TraceConnectionCreateStartParams`
      instance.

   .. attribute:: on_connection_create_end

      Property that gives access to the signals that will be executed when a
      request that created a new connection finishes its creation.

      ``params`` is :class:`aiohttp.TraceConnectionCreateEndParams`
      instance.

   .. attribute:: on_connection_reuseconn

      Property that gives access to the signals that will be executed when a
      request reuses a connection.

      ``params`` is :class:`aiohttp.TraceConnectionReuseconnParams`
      instance.

   .. attribute:: on_dns_resolvehost_start

      Property that gives access to the signals that will be executed when a
      request starts to resolve the domain related with the request.

      ``params`` is :class:`aiohttp.TraceDnsResolveHostStartParams`
      instance.

   .. attribute:: on_dns_resolvehost_end

      Property that gives access to the signals that will be executed when a
      request finishes to resolve the domain related with the request.

      ``params`` is :class:`aiohttp.TraceDnsResolveHostEndParams` instance.

   .. attribute:: on_dns_cache_hit

      Property that gives access to the signals that will be executed when a
      request was able to use a cached DNS resolution for the domain related
      with the request.

      ``params`` is :class:`aiohttp.TraceDnsCacheHitParams` instance.

   .. attribute:: on_dns_cache_miss

      Property that gives access to the signals that will be executed when a
      request was not able to use a cached DNS resolution for the domain related
      with the request.

      ``params`` is :class:`aiohttp.TraceDnsCacheMissParams` instance.

   .. attribute:: on_request_headers_sent

      Property that gives access to the signals that will be executed
      when request headers are sent.

      ``params`` is :class:`aiohttp.TraceRequestHeadersSentParams` instance.

      .. versionadded:: 3.8


.. class:: TraceRequestStartParams

   See :attr:`TraceConfig.on_request_start` for details.

   .. attribute:: method

       Method that will be used  to make the request.

   .. attribute:: url

       URL that will be used  for the request.

   .. attribute:: headers

       Headers that will be used for the request, can be mutated.


.. class:: TraceRequestChunkSentParams

   .. versionadded:: 3.1

   See :attr:`TraceConfig.on_request_chunk_sent` for details.

   .. attribute:: method

       Method that will be used  to make the request.

   .. attribute:: url

       URL that will be used  for the request.

   .. attribute:: chunk

       Bytes of chunk sent


.. class:: TraceResponseChunkReceivedParams

   .. versionadded:: 3.1

   See :attr:`TraceConfig.on_response_chunk_received` for details.

   .. attribute:: method

       Method that will be used  to make the request.

   .. attribute:: url

       URL that will be used  for the request.

   .. attribute:: chunk

       Bytes of chunk received


.. class:: TraceRequestEndParams

   See :attr:`TraceConfig.on_request_end` for details.

   .. attribute:: method

       Method used to make the request.

   .. attribute:: url

       URL used for the request.

   .. attribute:: headers

       Headers used for the request.

   .. attribute:: response

       Response :class:`ClientResponse`.


.. class:: TraceRequestExceptionParams

   See :attr:`TraceConfig.on_request_exception` for details.

   .. attribute:: method

       Method used to make the request.

   .. attribute:: url

       URL used for the request.

   .. attribute:: headers

       Headers used for the request.

   .. attribute:: exception

       Exception raised during the request.


.. class:: TraceRequestRedirectParams

   See :attr:`TraceConfig.on_request_redirect` for details.

   .. attribute:: method

       Method used to get this redirect request.

   .. attribute:: url

       URL used for this redirect request.

   .. attribute:: headers

       Headers used for this redirect.

   .. attribute:: response

       Response :class:`ClientResponse` got from the redirect.


.. class:: TraceConnectionQueuedStartParams

   See :attr:`TraceConfig.on_connection_queued_start` for details.

   There are no attributes right now.


.. class:: TraceConnectionQueuedEndParams

   See :attr:`TraceConfig.on_connection_queued_end` for details.

   There are no attributes right now.


.. class:: TraceConnectionCreateStartParams

   See :attr:`TraceConfig.on_connection_create_start` for details.

   There are no attributes right now.


.. class:: TraceConnectionCreateEndParams

   See :attr:`TraceConfig.on_connection_create_end` for details.

   There are no attributes right now.


.. class:: TraceConnectionReuseconnParams

   See :attr:`TraceConfig.on_connection_reuseconn` for details.

   There are no attributes right now.


.. class:: TraceDnsResolveHostStartParams

   See :attr:`TraceConfig.on_dns_resolvehost_start` for details.

   .. attribute:: host

       Host that will be resolved.


.. class:: TraceDnsResolveHostEndParams

   See :attr:`TraceConfig.on_dns_resolvehost_end` for details.

   .. attribute:: host

       Host that has been resolved.


.. class:: TraceDnsCacheHitParams

   See :attr:`TraceConfig.on_dns_cache_hit` for details.

   .. attribute:: host

       Host found in the cache.


.. class:: TraceDnsCacheMissParams

   See :attr:`TraceConfig.on_dns_cache_miss` for details.

   .. attribute:: host

       Host didn't find the cache.


.. class:: TraceRequestHeadersSentParams

   See :attr:`TraceConfig.on_request_headers_sent` for details.

   .. versionadded:: 3.8

   .. attribute:: method

       Method that will be used to make the request.

   .. attribute:: url

       URL that will be used for the request.

   .. attribute:: headers

       Headers that will be used for the request.
