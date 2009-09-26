﻿/*
	Alphora Dataphor
	© Copyright 2000-2008 Alphora
	This file is licensed under a modified BSD-license which can be found here: http://dataphor.org/dataphor_license.txt
*/

using System;
using System.ServiceModel;
using System.Collections.Generic;

using Alphora.Dataphor.DAE;
using Alphora.Dataphor.DAE.Contracts;
using Alphora.Dataphor.DAE.Server;

namespace Alphora.Dataphor.DAE.Client
{
	public class ClientConnection : ClientObject, IRemoteServerConnection
	{
		public ClientConnection(ClientServer AClientServer, string AConnectionName, string AClientHostName)
		{
			FClientServer = AClientServer;
			FConnectionName = AConnectionName;
			FClientHostName = AClientHostName;
		}
		
		private ClientServer FClientServer;
		public ClientServer ClientServer { get { return FClientServer; } }
		
		private IClientDataphorService GetServiceInterface()
		{
			return FClientServer.GetServiceInterface();
		}
		
		private string FClientHostName;
		public string ClientHostName { get { return FClientHostName; } }
		
		#region IRemoteServerConnection Members

		private string FConnectionName;
		public string ConnectionName { get { return FConnectionName; } }

		public IRemoteServerSession Connect(SessionInfo ASessionInfo)
		{
			IAsyncResult LResult = GetServiceInterface().BeginConnect(ASessionInfo, null, null);
			LResult.AsyncWaitHandle.WaitOne();
			return new ClientSession(this, ASessionInfo, GetServiceInterface().EndConnect(LResult));
		}

		public void Disconnect(IRemoteServerSession ASession)
		{
			IAsyncResult LResult = GetServiceInterface().BeginDisconnect(((ClientSession)ASession).SessionHandle, null, null);
			LResult.AsyncWaitHandle.WaitOne();
			GetServiceInterface().EndDisconnect(LResult);
		}

		#endregion

		#region IPing Members

		public void Ping()
		{
			throw new NotImplementedException();
		}

		#endregion
	}
}
