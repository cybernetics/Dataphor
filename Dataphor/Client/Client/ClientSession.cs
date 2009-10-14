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

namespace Alphora.Dataphor.DAE.Client
{
	public class ClientSession : ClientObject, IRemoteServerSession
	{
		public ClientSession(ClientConnection AClientConnection, SessionInfo ASessionInfo, SessionDescriptor ASessionDescriptor)
		{
			FClientConnection = AClientConnection;
			FSessionInfo = ASessionInfo;
			FSessionDescriptor = ASessionDescriptor;
		}
		
		private ClientConnection FClientConnection;
		public ClientConnection ClientConnection { get { return FClientConnection; } }
		
		private IClientDataphorService GetServiceInterface()
		{
			return FClientConnection.ClientServer.GetServiceInterface();
		}
		
		private SessionInfo FSessionInfo;
		
		private SessionDescriptor FSessionDescriptor;

		public int SessionHandle { get { return FSessionDescriptor.Handle; } }
		
		#region IRemoteServerSession Members

		public IRemoteServer Server
		{
			get { return FClientConnection.ClientServer; }
		}

		public IRemoteServerProcess StartProcess(ProcessInfo AProcessInfo, out int AProcessID)
		{
			try
			{
				IAsyncResult LResult = GetServiceInterface().BeginStartProcess(FSessionDescriptor.Handle, AProcessInfo, null, null);
				LResult.AsyncWaitHandle.WaitOne();
				ProcessDescriptor LProcessDescriptor = GetServiceInterface().EndStartProcess(LResult);
				AProcessID = LProcessDescriptor.ID;
				return new ClientProcess(this, AProcessInfo, LProcessDescriptor);
			}
			catch (FaultException<DataphorFault> LFault)
			{
				throw DataphorFaultUtility.FaultToException(LFault.Detail);
			}
		}

		public void StopProcess(IRemoteServerProcess AProcess)
		{
			try
			{
				IAsyncResult LResult = GetServiceInterface().BeginStopProcess(((ClientProcess)AProcess).ProcessHandle, null, null);
				LResult.AsyncWaitHandle.WaitOne();
				GetServiceInterface().EndStopProcess(LResult);
			}
			catch (FaultException<DataphorFault> LFault)
			{
				throw DataphorFaultUtility.FaultToException(LFault.Detail);
			}
		}

		#endregion

		#region IServerSessionBase Members

		public int SessionID
		{
			get { return FSessionDescriptor.ID; }
		}

		public SessionInfo SessionInfo
		{
			get { return FSessionInfo; }
		}

		#endregion
	}
}