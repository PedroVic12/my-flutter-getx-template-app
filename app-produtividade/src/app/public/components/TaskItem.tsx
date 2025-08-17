"use client";

import React from 'react';
import { Paper, ListItem, ListItemText, Typography, SxProps, Divider } from '@mui/material';
import { TaskCounter } from './TaskCounter';
import { Task } from '../types/Task';

// Função utilitária para o efeito glass
const getGlassStyles = (backgroundColor: string): SxProps => ({
  background: backgroundColor,
  backdropFilter: 'blur(8px)',
  WebkitBackdropFilter: 'blur(8px)',
  border: '1px solid rgba(255, 255, 255, 0.3)',
  boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
  borderRadius: '16px',
  transition: 'all 0.3s ease',
  '&:hover': {
    transform: 'translateY(-2px)',
    boxShadow: '0 6px 12px rgba(0, 0, 0, 0.15)',
  },
  '&::before': {
    content: '""',
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backdropFilter: 'blur(8px)',
    WebkitBackdropFilter: 'blur(8px)',
    borderRadius: 'inherit',
    zIndex: -1,
  }
});

// Função para determinar a cor baseada no count
const getBackgroundColor = (count: number): string => {
  if (count > 10) return 'rgba(75,0,130)';
  if (count > 7) return 'rgba(255, 223, 0, 0.25)';
  if (count > 4) return 'rgba(144, 238, 144, 0.25)';
  return 'rgba(220, 220, 220, 0.25)';
};

interface TaskItemProps {
  task: Task;
  onIncrement: (id: string) => void;
}

export const TaskItem: React.FC<TaskItemProps> = ({ task, onIncrement }) => {
  return (
    <Paper
      elevation={30}
      sx={{
        mb: 2,
        ...getGlassStyles(getBackgroundColor(task.count))
      }}
    >
      <ListItem sx={{ display: 'flex', alignItems: 'flex-start', gap: 2, py: 2 }}>
        <ListItemText
          primary={
            <Typography
              fontWeight='bold'
              sx={{ color: 'rgba(0, 0, 0, 0.87)', fontSize: '1.0rem' }}
            >
              {task.title}
              <Divider sx={{ borderBottomWidth: 2, borderColor: 'rgba(0, 0, 0, 0.87)' }} />
            </Typography>

          }
          secondary={
            <Typography
              variant="body2"
              sx={{ color: 'rgba(0, 0, 0, 0.87)', mt: 0.5 }}
            >
              {task.description}
            </Typography>
          }
          sx={{ flex: '1 1 auto', minWidth: 0, mr: 1 }}
        />
        <div style={{ flexShrink: 0 }}>
          <TaskCounter
            count={task.count}
            onIncrement={() => onIncrement(task.id)}
          />
        </div>
      </ListItem>
    </Paper>
  );
};